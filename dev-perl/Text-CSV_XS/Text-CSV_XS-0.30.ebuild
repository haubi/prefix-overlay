# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-CSV_XS/Text-CSV_XS-0.30.ebuild,v 1.3 2007/07/30 18:50:07 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="comma-separated values manipulation routines"
SRC_URI="mirror://cpan/authors/id/H/HM/HMBRAND/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~hmbrand/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
