# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cvs2cl/cvs2cl-2.71.ebuild,v 1.1 2008/11/12 19:54:50 vapier Exp $

EAPI="prefix"

DESCRIPTION="produces a GNU-style ChangeLog for CVS-controlled sources"
HOMEPAGE="http://www.red-bean.com/cvs2cl/"
SRC_URI="mirror://gentoo/${P}.pl.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lang/perl"

S=${WORKDIR}

maint_pkg_create() {
	set -x
	wget http://www.red-bean.com/cvs2cl/${PN}.pl
	mv ${PN}.pl ${P}.pl
	bzip2 ${P}.pl
	ls -l ${PWD}/${P}.pl.bz2
	set +x
}
#pkg_setup() { maint_pkg_create; }

src_install() {
	newbin ${P}.pl ${PN} || die
}
