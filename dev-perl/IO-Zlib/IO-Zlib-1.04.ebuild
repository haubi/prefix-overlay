# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Zlib/IO-Zlib-1.04.ebuild,v 1.14 2007/01/15 23:15:52 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="IO:: style interface to Compress::Zlib"
HOMEPAGE="http://search.cpan.org/~tomhughtes/"
SRC_URI="mirror://cpan/authors/id/T/TO/TOMHUGHES/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/Compress-Zlib
	dev-lang/perl"
