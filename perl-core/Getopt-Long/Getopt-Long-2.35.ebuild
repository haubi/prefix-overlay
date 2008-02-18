# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Getopt-Long/Getopt-Long-2.35.ebuild,v 1.12 2007/04/15 21:05:38 corsair Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Advanced handling of command line options"
SRC_URI="mirror://cpan/authors/id/J/JV/JV/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/J/JV/JV/${P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

DEPEND="virtual/perl-PodParser
		dev-lang/perl"
