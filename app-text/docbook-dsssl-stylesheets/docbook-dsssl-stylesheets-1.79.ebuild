# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-dsssl-stylesheets/docbook-dsssl-stylesheets-1.79.ebuild,v 1.18 2007/09/08 15:40:57 jer Exp $

EAPI="prefix"

inherit sgml-catalog

MY_P=${P/-stylesheets/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="DSSSL Stylesheets for DocBook."
HOMEPAGE="http://wiki.docbook.org/topic/DocBookDssslStylesheets"
SRC_URI="mirror://sourceforge/docbook/${MY_P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

RDEPEND="app-text/sgml-common"

sgml-catalog_cat_include "/etc/sgml/dsssl-docbook-stylesheets.cat" \
	"/usr/share/sgml/docbook/dsssl-stylesheets-${PV}/catalog"
sgml-catalog_cat_include "/etc/sgml/sgml-docbook.cat" \
	"/etc/sgml/dsssl-docbook-stylesheets.cat"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/${PN}-1.77.Makefile Makefile
}

src_compile() {
	return 0
}

src_install() {
	make \
		BINDIR="${ED}/usr/bin" \
		DESTDIR="${ED}/usr/share/sgml/docbook/dsssl-stylesheets-${PV}" \
		install || die

	dodir /usr/share/sgml/stylesheets/dsssl/

	if [ -d "${EPREFIX}"/usr/share/sgml/stylesheets/dsssl/docbook ] &&
		[ ! -L "${EPREFIX}"/usr/share/sgml/stylesheets/dsssl/docbook ]
	then
		ewarn "Not linking /usr/share/sgml/stylesheets/dsssl/docbook to"
		ewarn "/usr/share/sgml/docbook/dsssl-stylesheets-${PV}"
		ewarn "as directory already exists there.  Will assume you know"
		ewarn "what you're doing."
		return 0
	fi

	dosym /usr/share/sgml/docbook/dsssl-stylesheets-${PV} \
		/usr/share/sgml/stylesheets/dsssl/docbook

	dodoc BUGS ChangeLog README RELEASE-NOTES.txt WhatsNew
}
