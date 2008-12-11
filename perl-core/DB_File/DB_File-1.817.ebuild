# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/DB_File/DB_File-1.817.ebuild,v 1.1 2008/12/08 03:31:46 robbat2 Exp $

EAPI="prefix"

inherit perl-module multilib eutils

DESCRIPTION="A Berkeley DB Support Perl Module"
HOMEPAGE="http://www.cpan.org/modules/by-module/DB_File/${P}.readme"
SRC_URI="mirror://cpan/authors/id/P/PM/PMQS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl
		sys-libs/db"

SRC_TEST="do"

src_unpack() {
	unpack ${A}
	if [ $(get_libdir) != "lib" ] ; then
		sed -i -e "s:^LIB.*:LIB = /usr/$(get_libdir):" \
		${S}/config.in || die
	fi
	cd ${S}
	epatch ${FILESDIR}/DB_File-MakeMaker.patch
}
