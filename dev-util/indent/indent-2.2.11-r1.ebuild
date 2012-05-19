# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/indent/indent-2.2.11-r1.ebuild,v 1.7 2012/05/16 14:19:34 jer Exp $

EAPI=4

inherit autotools eutils

DESCRIPTION="Indent program source files"
HOMEPAGE="http://indent.isidore-it.eu/beautify.html"
SRC_URI="http://${PN}.isidore-it.eu/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="nls"

DEPEND="
	nls? ( sys-devel/gettext )
	app-text/texi2html
"
RDEPEND="
	nls? ( virtual/libintl )
"

INDENT_LINGUAS="
	ca da de eo et fi fr gl hu it ja ko nl pl pt_BR ru sk sv tr zh_TW
"

for indent_lingua in ${INDENT_LINGUAS}; do
	IUSE+=" linguas_${indent_lingua}"
done

src_prepare() {
	# Fix bug #94837
	local pofile
	for pofile in po/zh_TW*; do
		mv ${pofile} ${pofile/.Big5} || die
	done
	sed -i po/LINGUAS -e 's|zh_TW\.Big5|zh_TW|g' || die

	epatch \
		"${FILESDIR}"/${PV}-segfault.patch \
		"${FILESDIR}"/${PV}-texi2html-5.patch
	eautomake
}

src_configure() {
	econf $(use_enable nls)
}

src_test() {
	emake -C regression/
}

src_install() {
	# htmldir as set in configure is ignored in doc/Makefile*
	emake DESTDIR="${D}" htmldir="${EPREFIX}/usr/share/doc/${PF}/html" install 
	dodoc AUTHORS NEWS README ChangeLog ChangeLog-1990 ChangeLog-1998 ChangeLog-2001
}
