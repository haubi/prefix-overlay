# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libpcap/libpcap-0.9.7.ebuild,v 1.6 2007/09/27 14:25:59 jer Exp $

EAPI="prefix"

inherit autotools eutils multilib toolchain-funcs

DESCRIPTION="A system-independent library for user-level network packet capture"
HOMEPAGE="http://www.tcpdump.org/"
SRC_URI="http://www.tcpdump.org/release/${P}.tar.gz
	http://www.jp.tcpdump.org/release/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="ipv6"

DEPEND="!virtual/libpcap"
PROVIDE="virtual/libpcap"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.9.3-whitespace.diff
	epatch "${FILESDIR}"/${PN}-0.8.1-fPIC.patch
	epatch "${FILESDIR}"/${PN}-cross-linux.patch
	eautoreconf
}

src_compile() {
	econf $(use_enable ipv6) || die "bad configure"
	emake || die "compile problem"

	# no provision for this in the Makefile, so...
	local myopts
	case ${CHOST} in
		*-darwin*)
			myopts="-dynamiclib -install_name ${EPREFIX}/usr/$(get_libdir)/libpcap$(get_libname 0)"
		;;
		*)
			myopts="-Wl,-soname,libpcap$(get_libname 0) -shared -fPIC"
		;;
	esac
	
	$(tc-getCC) ${LDFLAGS} ${myopts} -o libpcap$(get_libname ${PV:0:3}) *.o \
		|| die "couldn't make a shared lib"
}

src_install() {
	emake DESTDIR=${D} install || die "emake install failed"

	# We need this to build pppd on G/FBSD systems
	if [[ "${USERLAND}" == "BSD" ]]; then
		insinto /usr/include
		doins pcap-int.h || die "failed to install pcap-int.h"
	fi

	insopts -m 755
	insinto /usr/$(get_libdir)
	doins libpcap$(get_libname ${PV:0:3})
	dosym libpcap$(get_libname ${PV:0:3}) /usr/$(get_libdir)/libpcap$(get_libname ${PV:0:1})
	dosym libpcap$(get_libname ${PV:0:3}) /usr/$(get_libdir)/libpcap$(get_libname)

	# We are not installing README.{Win32,aix,hpux,tru64} (bug 183057)
	dodoc CREDITS CHANGES FILES VERSION TODO README{,.dag,.linux,.macosx,.septel}
}
