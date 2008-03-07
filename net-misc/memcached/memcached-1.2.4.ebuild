# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/memcached/memcached-1.2.4.ebuild,v 1.2 2008/02/22 18:39:02 robbat2 Exp $

EAPI="prefix"

inherit eutils

MY_PV="${PV/_rc/-rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="High-performance, distributed memory object caching system"
HOMEPAGE="http://www.danga.com/memcached/"
SRC_URI="http://www.danga.com/memcached/dist/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nptl test"

RDEPEND=">=dev-libs/libevent-0.6
		 dev-lang/perl"
DEPEND="${RDEPEND}
		test? ( perl-core/Test-Harness >=dev-perl/Cache-Memcached-1.24 )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.2.2-fbsd.patch"
	# Merged in upstream r604
	#epatch "${FILESDIR}/${PN}-1.2.2-p-threads.patch"
}

src_compile() {
	econf $(use_enable nptl threads)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dobin scripts/memcached-tool

	dodoc AUTHORS ChangeLog NEWS README TODO doc/{CONTRIBUTORS,*.txt}

	newconfd "${FILESDIR}"/1.2.4/conf memcached
	newinitd "${FILESDIR}"/1.2.4/init memcached
}

pkg_postinst() {
	enewuser memcached -1 -1 /dev/null daemon

	elog "With this version of Memcached Gentoo now supports multiple instances."
	elog "To enable this you must create a symlink in /etc/init.d/ for each instance"
	elog "to /etc/init.d/memcached and create the matching conf files in /etc/conf.d/"
	elog "Please see Gentoo bug #122246 for more info"
}

src_test() {
	emake -j1 test || die "Failed testing"
}
