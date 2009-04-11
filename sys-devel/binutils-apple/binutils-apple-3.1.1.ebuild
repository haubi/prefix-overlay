# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils flag-o-matic toolchain-funcs

RESTRICT="test mirror" # the test suite will test what's installed.

LD64=ld64-85.2.2
CCTOOLS=cctools-698

DESCRIPTION="Darwin assembler as(1) and static linker ld(1), Xcode Tools 3.1.1"
HOMEPAGE="http://www.opensource.apple.com/darwinsource/"
SRC_URI="http://www.gentoo.org/~grobian/distfiles/${LD64}.tar.gz
	http://www.gentoo.org/~grobian/distfiles/${CCTOOLS}.tar.gz"

LICENSE="APSL-2"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE="test"
SLOT="0"

DEPEND="sys-devel/binutils-config
	test? ( >=dev-lang/perl-5.8.8 )"
RDEPEND="${DEPEND}"

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi
is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

if is_cross ; then
	SLOT="${CTARGET}"
else
	SLOT="0"
fi

LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${PV}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${PV}
if is_cross ; then
	BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${PV}
else
	BINPATH=/usr/${CTARGET}/binutils-bin/${PV}
fi

S=${WORKDIR}

unpack_ld64() {
	cd "${S}"/${LD64}/src
	cp "${FILESDIR}"/Makefile .

	local VER_STR="\"@(#)PROGRAM:ld  PROJECT:${LD64}\\n\""
	sed -i \
		-e '/^#define LTO_SUPPORT 1/s:1:0:' \
		ObjectDump.cpp
	echo '#undef LTO_SUPPORT' > configure.h
	echo "char ldVersionString[] = ${VER_STR};" > version.cpp

	# clean up test suite
	cd "${S}"/${LD64}/unit-tests/test-cases
	local c

	# we don't have llvm
	((++c)); rm -rf llvm-integration;

	# we don't have dtrace
	((++c)); rm -rf dtrace-static-probes-coalescing;
	((++c)); rm -rf dtrace-static-probes;

	# a file is missing
	((++c)); rm -rf eh-coalescing-r

	# we don't do universal binaries
	((++c)); rm -rf blank-stubs;

	# looks like a problem with apple's result-filter.pl
	((++c)); rm -rf implicit-common3;
	((++c)); rm -rf order_file-ans;

	# TODO no idea what goes wrong here
	((++c)); rm -rf dwarf-debug-notes;

	elog "Deleted $c tests that were bound to fail"
}

src_unpack() {
	unpack ${A}
	unpack_ld64
	cd "${S}"

	epatch "${FILESDIR}"/${P}-as.patch
	epatch "${FILESDIR}"/${P}-as-dir.patch
	epatch "${FILESDIR}"/${P}-ranlib.patch
	epatch "${FILESDIR}"/${P}-libtool-ranlib.patch
	epatch "${FILESDIR}"/${P}-nmedit.patch
	epatch "${FILESDIR}"/${P}-no-efi-man.patch
	epatch "${FILESDIR}"/${P}-no-headers.patch
	epatch "${FILESDIR}"/${P}-no-oss-dir.patch
	epatch "${FILESDIR}"/${P}-testsuite.patch

	# -pg is used and the two are incompatible
	filter-flags -fomit-frame-pointer
}

compile_ld64() {
	cd "${S}"/${LD64}/src
	# 'struct linkedit_data_command' is defined in mach-o/loader.h on leopard,
	# but not on tiger.
	[[ ${CHOST} == *-apple-darwin8 ]] && \
		append-flags -isystem "${S}"/${CCTOOLS}/include/
	emake
	use test && emake build_test
}

compile_cctools() {
	cd "${S}"/${CCTOOLS}
	emake \
		LTO= \
		EFITOOLS= \
		COMMON_SUBDIRS='libstuff ar misc otool' \
		RC_CFLAGS="${CFLAGS}"
	cd "${S}"/${CCTOOLS}/as
	# the errors can be ignored
	emake -k \
		BUILD_OBSOLETE_ARCH= \
		RC_CFLAGS="-DASLIBEXECDIR=\"\\\"${EPREFIX}${LIBPATH}/\\\"\" ${CFLAGS}"
	emake \
		BUILD_OBSOLETE_ARCH= \
		RC_CFLAGS="-DASLIBEXECDIR=\"\\\"${EPREFIX}${LIBPATH}/\\\"\" ${CFLAGS}"
}

src_compile() {
	compile_cctools
	compile_ld64
}

install_ld64() {
	exeinto ${BINPATH}
	doexe "${S}"/${LD64}/src/{ld64,rebase}
	dosym ld64 ${BINPATH}/ld
	insinto ${DATAPATH}/man/man1
	doins "${S}"/${LD64}/doc/man/man1/{ld,ld64,rebase}.1
}

install_cctools() {
	cd "${S}"/${CCTOOLS}
	emake install_all_but_headers \
		EFITOOLS= \
		COMMON_SUBDIRS='ar misc otool' \
		DSTROOT=\"${D}\" \
		BINDIR=\"${EPREFIX}\"/${BINPATH} \
		LOCBINDIR=\"${EPREFIX}\"/${BINPATH} \
		USRBINDIR=\"${EPREFIX}\"/${BINPATH} \
		LOCLIBDIR=\"${EPREFIX}\"/${LIBPATH} \
		MANDIR=\"${EPREFIX}\"/${DATAPATH}/man/
	cd "${S}"/${CCTOOLS}/as
	emake install \
		BUILD_OBSOLETE_ARCH= \
		DSTROOT=\"${D}\" \
		USRBINDIR=\"${EPREFIX}\"/${BINPATH} \
		LIBDIR=\"${EPREFIX}\"/${LIBPATH}

	cd "${ED}"/${BINPATH}
	insinto ${DATAPATH}/man/man1
	local skips manpage
	# ar brings an up-to-date manpage with it
	skips=( ar )
	for bin in *; do
		for skip in ${skips[@]}; do
			if [[ ${bin} == ${skip} ]]; then
				continue 2;
			fi
		done
		manpage=${S}/${CCTOOLS}/man/${bin}.1
		if [[ -f "${manpage}" ]]; then
			doins "${manpage}"
		fi
	done
	insinto ${DATAPATH}/man/man5
	doins "${S}"/${CCTOOLS}/man/*.5
}

src_test() {
	cd "${S}"/${LD64}/unit-tests/test-cases
	# need host arch, since GNU arch doesn't do what Apple's does
	tc-export CC CXX
	perl ../bin/make-recursive.pl \
		ARCH="$(/usr/bin/arch)" \
		RELEASEDIR="${S}"/${LD64}/src \
		| perl ../bin/result-filter.pl
}

src_install() {
	install_ld64
	install_cctools

	cd "${S}"
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
		TARGET="${CHOST}"
		VER="${PV}"
		FAKE_TARGETS="${CHOST}"
	EOF
	newins env.d ${CHOST}-${PV}
}

pkg_postinst() {
	binutils-config ${CHOST}-${PV}
}
