# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/zile/zile-2.3.3.ebuild,v 1.2 2009/03/06 13:46:09 ulm Exp $

EAPI="prefix"

DESCRIPTION="Zile is a small Emacs clone"
HOMEPAGE="http://www.gnu.org/software/zile/"
SRC_URI="mirror://gnu/zile/${P}.tar.gz"

LICENSE="GPL-3 FDL-1.2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="sys-libs/ncurses"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.3"

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS NEWS README THANKS || die

	rm ${ED}/usr/lib/charset.alias
}
