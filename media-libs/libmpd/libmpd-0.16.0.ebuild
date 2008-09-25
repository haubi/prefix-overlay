# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmpd/Attic/libmpd-0.16.0.ebuild,v 1.1 2008/09/24 18:06:56 angelos Exp $

EAPI="prefix 1"

DESCRIPTION="A library handling connection to a MPD server."
HOMEPAGE="http://gmpcwiki.sarine.nl/index.php/Libmpd"
SRC_URI="http://download.sarine.nl/Programs/gmpc/${PV}/${P}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.16:2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
