# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gpgme/gpgme-1.1.5.ebuild,v 1.2 2007/07/10 03:37:33 alonbl Exp $

EAPI="prefix"

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/(en)/related_software/gpgme/index.html"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/libgpg-error-1.4
	>=dev-libs/pth-1.2
	>=app-crypt/gnupg-1.9.20-r1"

RDEPEND="${DEPEND}
	dev-libs/libgcrypt"

src_compile() {
	econf \
		--with-pth=yes \
		--includedir=${EPREFIX}/usr/include/gpgme \
		--with-gpg=${EPREFIX}/usr/bin/gpg \
		--with-gpgsm=${EPREFIX}/usr/bin/gpgsm \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}
