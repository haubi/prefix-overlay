# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Archive-Tar/Archive-Tar-1.31.ebuild,v 1.4 2007/07/05 04:16:42 tgall Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl module for creation and manipulation of tar files"
HOMEPAGE="http://search.cpan.org/~kane/Archive-Tar-1.26/"
SRC_URI="mirror://cpan/authors/id/K/KA/KANE/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND="dev-perl/IO-Zlib
	dev-perl/IO-String
	>=virtual/perl-Test-Harness-2.26
	dev-lang/perl"

SRC_TEST="do"
