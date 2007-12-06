# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lzma-utils/lzma-utils-4.32.2.ebuild,v 1.5 2007/12/05 20:29:59 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="LZMA interface made easy"
HOMEPAGE="http://tukaani.org/lzma/"
SRC_URI="http://tukaani.org/lzma/lzma-${PV/_}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

RDEPEND="!app-arch/lzma"

S=${WORKDIR}/lzma-${PV/_}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
