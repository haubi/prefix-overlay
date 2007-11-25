# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/wgetpaste/wgetpaste-2.7.ebuild,v 1.2 2007/11/24 15:20:13 armin76 Exp $

EAPI="prefix"

DESCRIPTION="Command-line interface to various pastebins"
HOMEPAGE="http://wgetpaste.zlin.dk/"
SRC_URI="http://wgetpaste.zlin.dk/${PF}.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_install() {
	newbin ${P} ${PN}
}
