# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-vi/eselect-vi-1.1.5.ebuild,v 1.3 2007/12/26 16:58:16 cardoe Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages the /usr/bin/vi symlink"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/vi.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.6"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-prefix.patch

	eprefixify vi.eselect-${PV}
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/vi.eselect-${PVR}" vi.eselect || die
}
