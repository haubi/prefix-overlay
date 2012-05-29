# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.7.ebuild,v 1.2 2012/05/03 19:08:41 vapier Exp $

AUTOTOOLS_AUTO_DEPEND="no"
inherit autotools toolchain-funcs eutils

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://zlib.net/${P}.tar.gz
	http://www.gzip.org/zlib/${P}.tar.gz
 	http://www.zlib.net/current/beta/${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="minizip static-libs"

DEPEND="minizip? ( ${AUTOTOOLS_DEPEND} )"
RDEPEND="!<dev-libs/libxml2-2.7.7" #309623

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use minizip ; then
		pushd contrib/minizip > /dev/null || die
		eautoreconf
		popd > /dev/null
	fi

	epatch "${FILESDIR}"/${PN}-1.2.7-aix-soname.patch #213277

	# set soname on Solaris for GNU toolchain
	sed -i -e 's:Linux\* | linux\*:Linux\* | linux\* | SunOS\* | solaris\*:' configure || die
}

echoit() { echo "$@"; "$@"; }
src_compile() {
	tc-export CC
	case ${CHOST} in
	*-mingw*|mingw*)
		emake -f win32/Makefile.gcc STRIP=true prefix="${EPREFIX}"/usr PREFIX=${CHOST}- || die
		sed \
			-e 's|@prefix@|/usr|g' \
			-e 's|@exec_prefix@|${prefix}|g' \
			-e 's|@libdir@|${exec_prefix}/'$(get_libdir)'|g' \
			-e 's|@sharedlibdir@|${exec_prefix}/'$(get_libdir)'|g' \
			-e 's|@includedir@|${prefix}/include|g' \
			-e 's|@VERSION@|'${PV}'|g' \
			zlib.pc.in > zlib.pc || die
		;;
	*-mint*)
		echoit ./configure --static --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	*)	# not an autoconf script, so can't use econf
		echoit ./configure --shared --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	esac
	if use minizip ; then
		cd contrib/minizip
		econf $(use_enable static-libs static)
		emake || die
	fi
}

sed_macros() {
	# clean up namespace a little #383179
	# we do it here so we only have to tweak 2 files
	sed -i -r 's:\<(O[FN])\>:_Z_\1:g' "$@" || die
}
src_install() {
	case ${CHOST} in
	*-mingw*|mingw*)
		emake -f win32/Makefile.gcc install \
			BINARY_PATH="${ED}/usr/bin" \
			LIBRARY_PATH="${ED}/usr/$(get_libdir)" \
			INCLUDE_PATH="${ED}/usr/include" \
			SHARED_MODE=1 \
			|| die
		insinto /usr/share/pkgconfig
		doins zlib.pc || die
		;;

	*)
		emake install DESTDIR="${D}" LDCONFIG=: || die
		gen_usr_ldscript -a z
		;;
	esac
	sed_macros "${ED}"/usr/include/*.h

	dodoc FAQ README ChangeLog doc/*.txt

	# on winnt, additionally install the .dll files.
	if [[ ${CHOST} == *-winnt* ]]; then
		into /
		dolib libz$(get_libname ${PV}).dll
	fi

	if use minizip ; then
		cd contrib/minizip
		emake install DESTDIR="${D}" || die
		sed_macros "${ED}"/usr/include/minizip/*.h
		dodoc *.txt
	fi

	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/*.{a,la}
}
