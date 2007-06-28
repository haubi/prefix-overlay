# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/python-updater/python-updater-0.2.ebuild,v 1.16 2007/06/26 16:23:43 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Script used to remerge python packages when changing Python version."
HOMEPAGE="http://dev.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~kloeri/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| ( >=sys-apps/portage-2.1.2 sys-apps/pkgcore sys-apps/paludis )"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify ${P}
}

src_install()
{
	cd "${WORKDIR}"
	newsbin ${P} ${PN}
}
