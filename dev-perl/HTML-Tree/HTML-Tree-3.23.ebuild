# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTML-Tree/HTML-Tree-3.23.ebuild,v 1.11 2007/07/11 15:46:43 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A library to manage HTML-Tree in PERL"
HOMEPAGE="http://search.cpan.org/dist/"
SRC_URI="mirror://cpan/authors/id/P/PE/PETEK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/HTML-Tagset-3.03
	>=dev-perl/HTML-Parser-3.46
	dev-lang/perl"

SRC_TEST="do"

mydoc="MANIFEST README"
