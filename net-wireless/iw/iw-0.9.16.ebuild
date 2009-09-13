# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/iw/iw-0.9.16.ebuild,v 1.1 2009/09/11 13:30:54 patrick Exp $

inherit toolchain-funcs

DESCRIPTION="nl80211-based configuration utility for wireless devices using the mac80211 kernel stack"
HOMEPAGE="http://wireless.kernel.org/en/users/Documentation/iw"
SRC_URI="http://wireless.kernel.org/download/${PN}/${P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/libnl-1.1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

CC=$(tc-getCC)
LD=$(tc-getLD)

src_install() {
	emake install DESTDIR="${D}" || die "Failed to install"
}
