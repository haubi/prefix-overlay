# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-oodict/eselect-oodict-20061117.ebuild,v 1.8 2009/10/11 23:24:18 halcy0n Exp $

DESCRIPTION="Manages configuration of dictionaries for OpenOffice.Org."
HOMEPAGE="http://www.gentoo.org/"

SRC_URI="mirror://gentoo/oodict.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.2"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"
	sed -i \
		-e 's/OOO_DICTBASE="/OOO_DICTBASE=""\${EPREFIX}"/' \
		-e 's/MYSPELL_BASE="/MYSPELL_BASE=""\${EPREFIX}"/' \
		oodict.eselect-20061117 || die "sed oodict.eselect-20061117 failed"
}

src_install() {
	insinto /usr/share/eselect/modules
	cp "${WORKDIR}"/oodict.eselect-${PVR} "${T}"/oodict.eselect
	doins "${T}"/oodict.eselect
}
