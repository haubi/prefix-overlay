# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/zisofs-tools/zisofs-tools-1.0.8.ebuild,v 1.1 2008/10/31 21:17:58 dsd Exp $

inherit flag-o-matic

DESCRIPTION="User utilities for zisofs"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/fs/zisofs/"
SRC_URI="mirror://kernel/linux/utils/fs/zisofs/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static"

DEPEND=">=sys-libs/zlib-1.1.4"

src_compile() {
	use static && append-ldflags -static
	econf || die
	emake || die
}

src_install() {
	emake INSTALLROOT="${D}" install || die
	dodoc CHANGES INSTALL README
}
