# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/wgetpaste/wgetpaste-2.10.ebuild,v 1.1 2008/03/29 14:17:24 zlin Exp $

EAPI="prefix"

DESCRIPTION="Command-line interface to various pastebins"
HOMEPAGE="http://wgetpaste.zlin.dk/"
SRC_URI="http://wgetpaste.zlin.dk/${PF}.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_install() {
	newbin ${P} ${PN}
}
