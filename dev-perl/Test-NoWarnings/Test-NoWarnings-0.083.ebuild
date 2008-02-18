# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-NoWarnings/Test-NoWarnings-0.083.ebuild,v 1.4 2007/07/13 21:31:02 armin76 Exp $

EAPI="prefix"

inherit perl-module
IUSE=""

DESCRIPTION="Make sure you didn't emit any warnings while testing"
SRC_URI="mirror://cpan/authors/id/F/FD/FDALY/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~fdaly/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"

SRC_TEST="do"

DEPEND="dev-perl/Test-Tester
	dev-lang/perl"
