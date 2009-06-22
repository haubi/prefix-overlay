# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/perl-cleaner/perl-cleaner-1.04.3.ebuild,v 1.13 2009/02/05 05:39:37 darkside Exp $

inherit eutils

DESCRIPTION="User land tool for cleaning up old perl installs"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="app-shells/bash"
RDEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}/bin
	epatch "${FILESDIR}"/${P}-prefix.patch
	ebegin "Adjusting to prefix"
	sed -i \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
		perl-cleaner
	eend $?
}

src_install() {
	dobin bin/perl-cleaner || die
	doman man/perl-cleaner.1
}
