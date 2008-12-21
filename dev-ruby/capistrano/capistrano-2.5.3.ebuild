# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano/capistrano-2.5.3.ebuild,v 1.1 2008/12/20 12:42:17 graaff Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="A distributed application deployment system"
HOMEPAGE="http://capify.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/ruby-1.8.2
	>=dev-ruby/rubygems-1.3.0
	>=dev-ruby/net-ssh-2.0.0
	>=dev-ruby/net-sftp-2.0.0
	>=dev-ruby/net-scp-1.0.0
	>=dev-ruby/net-ssh-gateway-1.0.0
	>=dev-ruby/highline-1.2.7"
PDEPEND="dev-ruby/capistrano-launcher"

src_install() {
	gems_src_install

	# Deleted cap, as it will be provided by capistrano-launcher
	rm "${ED}/usr/bin/cap"
	rm "${ED}/${GEMSDIR}/bin/cap"
}
