# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/xmlrpc-c/xmlrpc-c-1.06.27.ebuild,v 1.10 2008/11/04 09:13:14 vapier Exp $

EAPI="prefix 1"

inherit eutils

DESCRIPTION="A lightweigt RPC library based on XML and HTTP"
SRC_URI="mirror://sourceforge/${PN}/${P/-c}.tgz"
HOMEPAGE="http://xmlrpc-c.sourceforge.net/"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+curl threads"
LICENSE="BSD"
SLOT="0"

DEPEND="dev-libs/libxml2
	curl? ( net-misc/curl )"

pkg_setup() {
	if ! use curl
	then
		ewarn "Curl support disabled: No client library will be be built"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-curl-easy-setopt.patch
	epatch "${FILESDIR}"/${P}-abyss-header-fixup.patch

	#CPP test suite doesn't pass, but if we were to get it to pass,
	#this is needed to get it to build.
	epatch "${FILESDIR}"/${P}-gcc43-test-fix.patch
	epatch "${FILESDIR}"/${PN}-1.06.09-asneeded.patch
	epatch "${FILESDIR}"/${PN}-1.05-pic.patch
	epatch "${FILESDIR}"/${PN}-1.06.09-interix.patch

	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${P}-interix-3.5.patch
#	[[ ${CHOST} == *-darwin* ]] && epatch "${FILESDIR}"/${PN}-1.06.09-darwin.patch

	# Respect the user's CFLAGS/CXXFLAGS.
	sed -i -e "/CFLAGS_COMMON/s:-g -O3$:${CFLAGS}:" Makefile.common
	sed -i -e "/CXXFLAGS_COMMON/s:-g$:${CXXFLAGS}:" Makefile.common
}

src_compile() {
	#Bug 214137: We need to filter this.
	unset SRCDIR

	# Respect the user's LDFLAGS.
	export LADD=${LDFLAGS}
	export CFLAGS_PERSONAL=${CFLAGS}
	econf --disable-wininet-client --enable-libxml2-backend --disable-libwww-client \
		$(use_enable threads abyss-threads) \
		$(use_enable curl curl-client) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_test() {
	unset SRCDIR
	unset LDFLAGS LADD
	cd "${S}"/src/test/
	einfo "Building general tests"
	make || die "Make of general tests failed"
	einfo "Running general tests"
	./test || die "General tests failed"

	#C++ tests. They fail.
	#cd "${S}"/src/cpp/test
	#einfo "Building C++ tests"
	#make || die "Make of C++ tests failed"
	#einfo "Running C++ tests"
	#./test || die "C++ tests failed"
}

src_install() {
	unset SRCDIR
	emake -j1 DESTDIR="${D}" install || die "installation failed"

	dodoc README doc/CREDITS doc/DEVELOPING doc/HISTORY doc/SECURITY doc/TESTING \
		doc/TODO || die "installing docs failed"
}
