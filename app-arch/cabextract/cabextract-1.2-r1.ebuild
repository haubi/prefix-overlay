# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cabextract/cabextract-1.2-r1.ebuild,v 1.7 2009/05/30 16:54:58 nixnut Exp $

inherit flag-o-matic

DESCRIPTION="Extracts files from Microsoft .cab files"
HOMEPAGE="http://www.cabextract.org.uk/"
SRC_URI="http://www.kyz.uklinux.net/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="extra-tools"

DEPEND="x86-interix? ( >=sys-devel/gettext-0.16 )
	mips-irix? ( >=sys-devel/gettext-0.16 )"
RDEPEND="extra-tools? ( dev-lang/perl )
	${DEPEND}"

src_compile() {
	# cabextract doesn't think about linking libintl at all.
	# on interix[35] this means linking fails, since there is no
	# getopt(), and only the included getopt needs gettext.
	[[ ${CHOST} == *-interix[35]* || ${CHOST} == *-irix* ]] && append-libs intl

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO doc/magic
	dohtml doc/wince_cab_format.html
	if use extra-tools; then
		dobin src/{wince_info,wince_rename,cabinfo} || die
	fi
}
