# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/lftp/lftp-3.99.6.ebuild,v 1.1 2009/07/30 17:20:51 jer Exp $

EAPI="2"

inherit eutils autotools libtool

DESCRIPTION="A sophisticated ftp/sftp/http/https client and file transfer program"
HOMEPAGE="http://lftp.yar.ru/"
SRC_URI="ftp://ftp.yar.ru/lftp/devel/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="ssl gnutls socks5 nls"

RDEPEND=">=sys-libs/ncurses-5.1
		socks5? (
			>=net-proxy/dante-1.1.12
			virtual/pam )
		ssl? (
			gnutls? ( >=net-libs/gnutls-1.2.3 )
			!gnutls? ( >=dev-libs/openssl-0.9.6 )
		)
		virtual/libc
		>=sys-libs/readline-5.1"

DEPEND="
	${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-lang/perl
	=sys-devel/libtool-2*
"

src_prepare() {
	epatch "${FILESDIR}/${PN}-gnutls.patch"
	epatch "${FILESDIR}/${PN}-3.99.5-torrent_la.patch"
	eautoreconf
	epatch "${FILESDIR}"/${PN}-3.7.14-darwin-bundle.patch
	elibtoolize # for Darwin bundles
}

src_configure() {
	local myconf="$(use_enable nls) --enable-packager-mode"

	if use ssl && use gnutls ; then
		myconf="${myconf} --without-openssl"
	elif use ssl && ! use gnutls ; then
		myconf="${myconf} --without-gnutls --with-openssl=${EPREFIX}/usr"
	else
		myconf="${myconf} --without-gnutls --without-openssl"
	fi

	use socks5 && myconf="${myconf} --with-socksdante=${EPREFIX}/usr" \
		|| myconf="${myconf} --without-socksdante"

	econf \
		--sysconfdir="${EPREFIX}"/etc/lftp \
		--with-modules \
		${myconf} || die "econf failed"
}

src_install() {
	emake install DESTDIR="${D}" || die

	rm -f "${ED}"/usr/lib/charset.alias

	dodoc BUGS ChangeLog FAQ FEATURES MIRRORS \
			NEWS README* THANKS TODO
}
