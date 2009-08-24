# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-dtd/docbook-sgml-dtd-3.0-r3.ebuild,v 1.7 2009/08/23 16:02:38 flameeyes Exp $

inherit sgml-catalog eutils

MY_P="docbk30"
DESCRIPTION="Docbook SGML DTD 3.0"
HOMEPAGE="http://www.docbook.org/sgml/"
SRC_URI="http://www.oasis-open.org/docbook/sgml/${PV}/${MY_P}.zip"

LICENSE="X11"
SLOT="3.0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE=""

DEPEND=">=app-arch/unzip-5.41"
RDEPEND="app-text/sgml-common"

S=${WORKDIR}

sgml-catalog_cat_include "${EPREFIX}/etc/sgml/sgml-docbook-${PV}.cat" \
	"${EPREFIX}/usr/share/sgml/docbook/sgml-dtd-${PV}/catalog"
sgml-catalog_cat_include "${EPREFIX}/etc/sgml/sgml-docbook-${PV}.cat" \
	"${EPREFIX}/etc/sgml/sgml-docbook.cat"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-catalog.diff || die
}

src_install () {

	insinto /usr/share/sgml/docbook/sgml-dtd-${PV}
	doins *.dcl *.dtd *.mod
	newins docbook.cat catalog

	dodoc *.txt
}
