# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cabextract/cabextract-1.2.ebuild,v 1.11 2008/09/10 06:42:38 pva Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Extracts files from Microsoft .cab files"
HOMEPAGE="http://www.cabextract.org.uk/"
SRC_URI="http://www.kyz.uklinux.net/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="x86-interix? ( >=sys-devel/gettext-0.16 )"
RDEPEND=""

src_compile() {
	# cabextract doesn't think about linking libintl at all.
	# on interix[35] this means linking fails, since there is no
	# getopt(), and only the included getopt needs gettext.
	[[ ${CHOST} == *-interix[35]* ]] && append-ldflags -lintl

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO doc/magic
	dohtml doc/wince_cab_format.html
}
