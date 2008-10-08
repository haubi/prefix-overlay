# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/mongrel/mongrel-1.1.5.ebuild,v 1.4 2008/10/07 21:12:47 bluebird Exp $

EAPI="prefix"

inherit gems

DESCRIPTION="A small fast HTTP library and server that runs Rails, Camping, and Nitro apps"
HOMEPAGE="http://mongrel.rubyforge.org/"

LICENSE="|| ( mongrel GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

USE_RUBY="any"
DEPEND=">=dev-ruby/daemons-1.0.3
	>=dev-ruby/gem_plugin-0.2.3
	>=dev-ruby/fastthread-1.0.1
	>=dev-ruby/cgi_multipart_eof_fix-2.4"
