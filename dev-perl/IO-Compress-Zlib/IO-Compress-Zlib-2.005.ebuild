# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Zlib/IO-Compress-Zlib-2.005.ebuild,v 1.4 2007/11/10 12:20:39 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Read/Write compressed files"
HOMEPAGE="http://search.cpan.org/~pqms"
SRC_URI="mirror://cpan/authors/id/P/PM/PMQS/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/IO-Compress-Base-2.005
	dev-perl/Compress-Raw-Zlib
	dev-lang/perl"

SRC_TEST="do"
