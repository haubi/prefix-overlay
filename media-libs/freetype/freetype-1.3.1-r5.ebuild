# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/freetype-1.3.1-r5.ebuild,v 1.14 2007/10/15 11:04:04 aballier Exp $

EAPI="prefix"

# r3 change by me (danarmak): there's a contrib dir inside the freetype1
# sources with important utils: ttf2bdf, ttf2pfb, ttf2pk, ttfbanner.
# These aren't build together with the main tree: you must configure/make
# separately in each util's directory. However ttf2pfb doesn't compile
# properly. Therefore we download freetype1-contrib.tar.gz which is newer
# and coresponds to freetype-pre1.4. (We don't have an ebuild for that
# because it's not stable?) We extract it to freetype-1.3.1/freetype1-contrib
# and build from there.
# When we update to freetype-pre1.4 or any later version, we should use
# the included contrib directory and not download any additional files.

inherit eutils libtool flag-o-matic

P2=${PN}1-contrib
DESCRIPTION="TTF-Library"
HOMEPAGE="http://www.freetype.org/"
SRC_URI="ftp://ftp.freetype.org/freetype/freetype1/${P}.tar.gz
	ftp://ftp.freetype.org/freetype/freetype1/${P2}.tar.gz
	http://ftp.sunet.se/pub/text-processing/freetype/freetype1/${P}.tar.gz
	http://ftp.sunet.se/pub/text-processing/freetype/freetype1/${P2}.tar.gz"

LICENSE="FTL"
SLOT="1"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE="nls tetex"

DEPEND="tetex? ( virtual/latex-base )"
RDEPEND="${DEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {

	cd ${WORKDIR}
	unpack ${P}.tar.gz
	# freetype1-contrib goes under freetype-1.3.1
	cd ${S}
	unpack ${P2}.tar.gz

	cd ${S}
	# remove unneeded include for BSD (#104016)
	epatch ${FILESDIR}/${P}-malloc.patch

	elibtoolize

}

src_compile() {
	local myconf

	use nls || myconf="${myconf} --disable-nls"

	# nls is currently broken, and I don't feel like fix it properly, the
	# problem is the sub modules don't linking properly because of missing
	# libint_gettext symbols.
	[[ ${CHOST} == *-freebsd* ]] && myconf="${myconf} --disable-nls"

	econf ${myconf} || die

	# Make a small fix to disable tests
	# Now X11 is no longer required
	cp Makefile Makefile.orig
	sed -e "s:ttlib tttest ttpo:ttlib ttpo:" Makefile.orig > Makefile

	make || die

	# make contrib utils

	use tetex && myconf="${myconf} --with-kpathsea-dir=${EPREFIX}/usr/lib"

	for x in ttf2bdf ttf2pfb ttf2pk ttfbanner ; do
		cd ${S}/freetype1-contrib/${x}
		econf ${myconf} || die
		make || die
	done
}

src_install() {
	cd lib

	# Seems to require a shared libintl (getetxt comes only with a static one
	# But it seems to work without problems

	make -f arch/unix/Makefile prefix=${ED}/usr libdir=${ED}/usr/$(get_libdir) install || die

	cd ${S}/po
	make prefix=${ED}/usr libdir=${ED}/usr/$(get_libdir) install || die

	cd ${S}
	dodoc announce PATENTS README readme.1st
	dodoc docs/*.txt docs/FAQ docs/TODO
	dohtml -r docs

	# install contrib utils, omit t1asm (conflicts with t1lib)
	# and getafm (conflicts with psutils)
	cd ${S}/freetype1-contrib
	into /usr
	dobin ttf2bdf/ttf2bdf ttf2pfb/.libs/ttf2pfb \
		ttf2pk/.libs/ttf2pk ttf2pk/.libs/ttf2tfm \
		ttfbanner/.libs/ttfbanner \
		|| die
	if use tetex ; then
		insinto /usr/share/texmf/ttf2pk
		doins ttf2pk/data/* || die
		insinto /usr/share/texmf/ttf2pfb
		doins ttf2pfb/Uni-T1.enc || die
	fi
	newman ttf2bdf/ttf2bdf.man ttf2bdf/ttf2bdf.man.1
	doman ttf2bdf/ttf2bdf.man.1
	docinto contrib
	dodoc ttf2pk/ttf2pk.doc
}
