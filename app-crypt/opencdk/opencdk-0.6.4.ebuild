# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/opencdk/opencdk-0.6.4.ebuild,v 1.1 2007/09/05 20:16:44 alonbl Exp $

EAPI="prefix"

DESCRIPTION="Open Crypto Development Kit for basic OpenPGP message manipulation"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="ftp://ftp.gnutls.org/pub/gnutls/opencdk/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="doc"

RDEPEND=">=dev-libs/libgcrypt-1.2.0"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5.6"

src_install() {
	make DESTDIR="${D}" install || die "installed failed"
	dodoc AUTHORS ChangeLog NEWS README README-alpha THANKS TODO
	use doc && dohtml doc/opencdk-api.html
}
