# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/nokogiri/nokogiri-1.2.1.ebuild,v 1.3 2009/03/18 17:59:26 ranger Exp $

inherit gems
USE_RUBY="ruby18"

DESCRIPTION="Nokogiri is an HTML, XML, SAX, and Reader parser."
HOMEPAGE="http://nokogiri.rubyforge.org/"
LICENSE="MIT"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND="dev-libs/libxml2
	dev-libs/libxslt"
DEPEND="${RDEPEND}"
