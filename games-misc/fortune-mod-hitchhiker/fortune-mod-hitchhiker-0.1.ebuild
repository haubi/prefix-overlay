# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/fortune-mod-hitchhiker/fortune-mod-hitchhiker-0.1.ebuild,v 1.12 2006/10/08 02:24:19 vapier Exp $

MY_P=${PN/-mod/}
DESCRIPTION="Quotes from Hitchhikers Guide to the Galaxy"
HOMEPAGE="http://www.splitbrain.org/projects/fortunes/hg2g"
SRC_URI="http://www.splitbrain.org/_media/projects/fortunes/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
RESTRICT="mirror"

RDEPEND="games-misc/fortune-mod"

S=${WORKDIR}/${MY_P}

src_install() {
	insinto /usr/share/fortune
	doins hitchhiker hitchhiker.dat || die
}
