# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Zlib/IO-Zlib-1.07.ebuild,v 1.7 2008/02/05 10:22:03 corsair Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="IO:: style interface to Compress::Zlib"
HOMEPAGE="http://search.cpan.org/~tomhughtes/"
SRC_URI="mirror://cpan/authors/id/T/TO/TOMHUGHES/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/Compress-Zlib
	dev-lang/perl"
