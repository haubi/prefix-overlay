# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.2.0.ebuild,v 1.3 2007/06/18 04:07:51 vapier Exp $

EAPI="prefix"

PATCH_VER="1.2"
UCLIBC_VER="1.0"

ETYPE="gcc-compiler"

# whether we should split out specs files for multiple {PIE,SSP}-by-default
# and vanilla configurations.
SPLIT_SPECS=no #${SPLIT_SPECS-true} hard disable until #106690 is fixed

inherit toolchain flag-o-matic

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking"

LICENSE="GPL-2 LGPL-2.1"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-solaris"

RDEPEND=">=sys-libs/zlib-1.1.4
	|| ( >=sys-devel/gcc-config-1.3.12-r4 app-admin/eselect-compiler )
	virtual/libiconv
	fortran? (
		>=dev-libs/gmp-4.2.1
		>=dev-libs/mpfr-2.2.0_p10
	)
	!build? (
		gcj? (
			gtk? (
				|| ( ( x11-libs/libXt x11-libs/libX11 x11-libs/libXtst x11-proto/xproto x11-proto/xextproto ) virtual/x11 )
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen dev-util/dejagnu )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875"
case ${CHOST} in
	*-darwin*) DEPEND="${DEPEND} ${CATEGORY}/odcctools" ;;
	*-aix*)    DEPEND="${DEPEND} ${CATEGORY}/native-cctools" ;;
# future: for Solaris || ( binutils native-cctools ) ?
	*)         DEPEND="${DEPEND}
		|| ( ppc? ( >=${CATEGORY}/binutils-2.17 )
			ppc64? ( >=${CATEGORY}/binutils-2.17 )
			>=${CATEGORY}/binutils-2.15.94 )" ;;
esac
PDEPEND="|| ( sys-devel/gcc-config app-admin/eselect-compiler )"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.3.6 ) )"
fi

src_unpack() {
	gcc_src_unpack

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.0.2/gcc-4.0.2-softfloat.patch
}

src_compile() {
	case ${CHOST} in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld"
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as"
		;;
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
	esac
	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, so force it into our own bash
	export CONFIG_SHELL="${EPREFIX}/bin/sh"
	gcc_src_compile
}
