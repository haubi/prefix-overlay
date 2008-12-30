# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.3.2.ebuild,v 1.9 2008/12/29 09:38:06 vapier Exp $

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
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.2.1
	>=dev-libs/mpfr-2.3
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( sys-devel/autogen dev-util/dejagnu )
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	kernel_Darwin? ( ${CATEGORY}/binutils-apple )
	kernel_AIX? ( ${CATEGORY}/native-cctools )
	!kernel_Darwin? ( !kernel_AIX? (
		!prefix? ( amd64? (
			>=sys-libs/glibc-2.7-r2
			multilib? (
				gcj? ( app-emulation/emul-linux-x86-xlibs )
			)
		) )
		ppc? ( >=${CATEGORY}/binutils-2.17 )
		ppc64? ( >=${CATEGORY}/binutils-2.17 )
		>=${CATEGORY}/binutils-2.15.94
	) )"
PDEPEND=">=sys-devel/gcc-config-1.4"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} !prefix? ( elibc_glibc? ( >=sys-libs/glibc-2.6 ) )"
fi

src_unpack() {
	gcc_src_unpack

	# work around http://gcc.gnu.org/bugzilla/show_bug.cgi?id=33637
	#doesn't apply
#	epatch "${FILESDIR}"/4.2.2/targettools-checks.patch

	# http://bugs.gentoo.org/show_bug.cgi?id=201490
	epatch "${FILESDIR}"/4.2.2/gentoo-fixincludes.patch

	# http://gcc.gnu.org/bugzilla/show_bug.cgi?id=27516
	epatch "${FILESDIR}"/4.3.0/treelang-nomakeinfo.patch

	# add support for 64-bits native target on Solaris
	epatch "${FILESDIR}"/4.3.0/solarisx86_64.patch

	# make sure 64-bits native targets don't screw up the linker paths
	epatch "${FILESDIR}"/solaris-searchpath.patch
	epatch "${FILESDIR}"/no-libs-for-startfile.patch

	# interix patch from http://gcc.gnu.org/bugzilla/show_bug.cgi?id=15212
	#doesn't apply
#	epatch "${FILESDIR}"/4.2.2/interix-x86.patch.bz2
	# gcc sources are polluted with old stuff for interix 3.5 not needed here
	epatch "${FILESDIR}"/4.2.2/interix-3.5-x86.patch

	epatch "${FILESDIR}"/gcj-4.3.1-iconvlink.patch

	use vanilla && return 0

	[[ ${CHOST} == ${CTARGET} ]] && epatch "${FILESDIR}"/gcc-spec-env.patch

	[[ ${CTARGET} == *-softfloat-* ]] && epatch "${FILESDIR}"/4.3.2/gcc-4.3.2-softfloat.patch
}

src_compile() {
	case ${CTARGET} in
		*-solaris*)
			# todo: some magic for native vs. GNU linking?
			EXTRA_ECONF="${EXTRA_ECONF} --with-gnu-ld --with-gnu-as"
		;;
		*-aix*)
			# AIX doesn't use GNU binutils, because it doesn't produce usable
			# code
			EXTRA_ECONF="${EXTRA_ECONF} --without-gnu-ld --without-gnu-as"
			append-ldflags -Wl,-bbigtoc,-bmaxdata:0x10000000 # bug#194635
		;;
		*-darwin7)
			# libintl triggers inclusion of -lc which results in multiply
			# defined symbols, so disable nls
			EXTRA_ECONF="${EXTRA_ECONF} --disable-nls"
		;;
	esac
	# Since GCC 4.1.2 some non-posix (?) /bin/sh compatible code is used, at
	# least on Solaris, and AIX /bin/sh is ways too slow,
	# so force it into our own bash.
	export CONFIG_SHELL="${EPREFIX}/bin/sh"
	gcc_src_compile
}

src_install() {
	toolchain_src_install

	case ${CTARGET} in
		*-interix*)
			# interix delivers libdl and dlfcn.h with gcc-3.3.
			# Since those parts are perfectly usable by this gcc (and
			# required for example by perl), we simply can reuse them.
			# As libdl is in /usr/lib, we only need to copy dlfcn.h.
			cp /opt/gcc.3.3/include/dlfcn.h "${ED}${INCLUDEPATH}" \
			|| die "Cannot gain /opt/gcc.3.3/include/dlfcn.h"
		;;
	esac
}

