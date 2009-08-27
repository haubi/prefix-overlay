# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/gorg/gorg-0.6.3-r3.ebuild,v 1.1 2009/08/24 16:43:06 ramereth Exp $

EAPI=2

inherit ruby eutils

DESCRIPTION="Back-end XSLT processor for an XML-based web site"
HOMEPAGE="http://gentoo.neysx.org/mystuff/gorg/gorg.xml"
SRC_URI="http://gentoo.neysx.org/mystuff/gorg/${P}.tgz"
IUSE="apache2 fastcgi mysql"

SLOT="0"
USE_RUBY="ruby18"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DEPEND="virtual/ruby
	>=dev-libs/libxml2-2.6.16
	>=dev-libs/libxslt-1.1.12"
RDEPEND="${DEPEND}
	mysql? ( >=dev-ruby/ruby-dbi-0.0.21[mysql] )
	apache2? ( www-servers/apache
		fastcgi? ( www-apache/mod_fcgid ) )
	fastcgi? ( >=dev-ruby/ruby-fcgi-0.8.5-r1 )"

pkg_setup() {
	enewgroup gorg
	enewuser  gorg -1 -1 -1 gorg
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	
	epatch "${FILESDIR}/${P}-prefix.patch"
	eprefixify bin/gorg etc/gorg/gorg.conf.sample \
		etc/gorg/lighttpd.conf.sample etc/gorg/vhost.sample lib/gorg/base.rb \
		lib/gorg/cgi-bin/gorg.cgi lib/gorg/cgi-bin/search.cgi \
		lib/gorg/fcgi-bin/gorg.fcgi
}

src_compile() {
	# Fix listen issue w/ webrick
	sed -i -e 's/WEBrick::HTTPServer.new(/WEBrick::HTTPServer.new( :BindAddress=>"127.0.0.1",/' lib/gorg/www.rb

	ruby_src_compile
}

src_install() {
	ruby_einstall

	# install doesn't seem to chmod these correctly, forcing it here
	SITE_LIB_DIR=`$RUBY -r rbconfig -e 'puts Config::CONFIG["sitelibdir"]'`
	chmod +x "${D}"/${SITE_LIB_DIR}/gorg/cgi-bin/*.cgi
	chmod +x "${D}"/${SITE_LIB_DIR}/gorg/fcgi-bin/*.fcgi

	keepdir /etc/gorg; insinto /etc/gorg ; doins etc/gorg/*

	if use prefix; then
		diropts -m0770; keepdir /var/cache/gorg
	else
		diropts -m0770 -o gorg -g gorg; keepdir /var/cache/gorg
	fi

	dodoc Changelog README
}
