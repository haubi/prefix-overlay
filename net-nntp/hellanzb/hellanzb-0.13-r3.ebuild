# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-nntp/hellanzb/hellanzb-0.13-r3.ebuild,v 1.1 2007/11/22 23:38:51 aballier Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="Retrieves and processes .nzb files"
HOMEPAGE="http://www.hellanzb.com/"
SRC_URI="http://www.hellanzb.com/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="libnotify"

RDEPEND=">=dev-python/twisted-2.0
		dev-python/twisted-web
		|| ( app-arch/unrar
			 app-arch/rar )
		app-arch/par2cmdline
		libnotify? ( dev-python/notify-python )"

DEPEND=""

DOCS="CHANGELOG CREDITS PKG-INFO README"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-datafiles.patch"
	epatch "${FILESDIR}/${P}-Fix_conf_file_search_path.patch"
	epatch "${FILESDIR}/${P}-Choose_interface_to_bind_on.patch"
	epatch "${FILESDIR}/${P}-fix_multiples_hosts.diff"
}

src_install() {
	distutils_src_install

	# scripts aren't prefixified, take care to also set PATH correctly if you do
	newconfd "${FILESDIR}/hellanzb.conf" hellanzb
	newinitd "${FILESDIR}/hellanzb.init" hellanzb

	insinto etc
	doins etc/hellanzb.conf.sample
}

pkg_postinst() {
	elog "You can start hellanzb in the background automatically by using"
	elog "the init-script. To do this, add it to your default runlevel:"
	elog ""
	elog "    rc-update add hellanzb default"
	elog ""
	elog "Use this command to start the daemon now:"
	elog ""
	elog "    /etc/init.d/hellanzb start"
	elog ""
	elog "You will have to config /etc/conf.d/hellanzb before the init-script"
	elog "will work. It is recommended that you change the user under which"
	elog "the daemon will run."
}
