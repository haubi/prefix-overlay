# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf-archive/autoconf-archive-2008.04.17.ebuild,v 1.1 2008/04/20 19:13:13 vapier Exp $

EAPI="prefix"

inherit eutils

MY_PV=${PV//./-}
DESCRIPTION="GNU Autoconf Macro Archive"
HOMEPAGE="http://autoconf-archive.cryp.to/"
SRC_URI="http://autoconf-archive.cryp.to/${PN}-${MY_PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="sys-devel/automake
	sys-devel/autoconf"

S=${WORKDIR}/${PN}-${MY_PV}

src_install() {
	emake install DESTDIR="${D}" || die
	dodir /usr/share/doc
	mv "${ED}"/usr/share/{${PN},doc/${PF}} || die
}
