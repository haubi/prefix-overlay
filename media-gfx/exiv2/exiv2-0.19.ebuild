# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/exiv2/exiv2-0.19.ebuild,v 1.8 2010/04/18 19:24:55 maekke Exp $

EAPI="2"

inherit eutils multilib toolchain-funcs

DESCRIPTION="EXIF and IPTC metadata C++ library and command line utility"
HOMEPAGE="http://www.exiv2.org/"
SRC_URI="http://www.exiv2.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="contrib doc examples nls unicode xmp zlib"
IUSE_LINGUAS="de es fi fr pl ru sk"
IUSE="${IUSE} $(printf 'linguas_%s ' ${IUSE_LINGUAS})"

RDEPEND="
	virtual/libiconv
	nls? ( virtual/libintl )
	xmp? ( dev-libs/expat )
	zlib? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}
	contrib? ( >=dev-libs/boost-1.37 )
	doc? (
		dev-lang/python
		app-doc/doxygen
		dev-libs/libxslt
		dev-util/pkgconfig
		media-gfx/graphviz
	)
	nls? ( sys-devel/gettext )
"

src_prepare() {
	epatch "${FILESDIR}"/${P}-syntax-fix.patch

	if use unicode; then
		for i in doc/cmd.txt; do
			echo ">>> Converting "${i}" to UTF-8"
			iconv -f LATIN1 -t UTF-8 "${i}" > "${i}~" && mv -f "${i}~" "${i}" || rm -f "${i}~"
		done
	fi

	if use doc; then
		echo ">>> Updating doxygen config"
		doxygen 2>&1 >/dev/null -u config/Doxyfile
	fi

	if use contrib; then
		# create build environment for contrib
		ln -snf ../../src contrib/organize/exiv2
		sed -i -e 's:/usr/local/include/.*:'"${EPREFIX}"'/usr/include:g' \
			-e 's:/usr/local/lib/lib:-l:g' -e 's:-gcc..-mt-._..\.a::g' \
			contrib/organize/boost.mk
	fi
}

src_configure() {
	local myconf="$(use_enable nls) $(use_enable xmp)"
	use zlib || myconf="${myconf} --without-zlib"  # plain 'use_with' fails

	# Bug #78720. amd64/gcc-3.4/-fvisibility* fail.
	if [[ $(gcc-major-version) -lt 4 ]]; then
		use amd64 && myconf="${myconf} --disable-visibility"
	fi

	econf ${myconf}
}

src_compile() {
	# Needed for Solaris because /bin/sh is not a bash, bug #245647
	sed -i -e "s:/bin/sh:${EPREFIX}/bin/sh:" src/Makefile || die "sed failed"
	emake || die "emake failed"

	if use contrib; then
		emake -C contrib/organize \
			LDFLAGS="\$(BOOST_LIBS) -L../../src -lexiv2 ${LDFLAGS}" \
			CPPFLAGS="${CPPFLAGS} -I\$(BOOST_INC_DIR) -I. -DEXV_HAVE_STDINT_H" \
		|| die "emake organize failed"
	fi

	if use doc; then
		emake doc || die "emake doc failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if use contrib; then
		emake DESTDIR="${D}" -C contrib/organize install || die "emake install organize failed"
	fi

	dodoc README doc/{ChangeLog,cmd.txt}
	use xmp && dodoc doc/{COPYING-XMPSDK,README-XMP,cmdxmp.txt}
	use doc && dohtml -r doc/html/.
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins samples/*.cpp
	fi
}

pkg_postinst() {
	ewarn
	ewarn "PLEASE PLEASE take note of this:"
	ewarn "Please make *sure* to run revdep-rebuild now"
	ewarn "Certain things on your system may have linked against a"
	ewarn "different version of exiv2 -- those things need to be"
	ewarn "recompiled. Sorry for the inconvenience!"
	ewarn
}
