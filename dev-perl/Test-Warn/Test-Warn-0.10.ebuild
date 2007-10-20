# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Warn/Test-Warn-0.10.ebuild,v 1.4 2007/08/09 15:17:52 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl extension to test methods for warnings"
HOMEPAGE="http://search.cpan.org/~chorny/"
SRC_URI="mirror://cpan/authors/id/C/CH/CHORNY/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/Test-Exception
	>=dev-perl/Sub-Uplevel-0.09-r1
	dev-perl/Array-Compare
	dev-perl/Tree-DAG_Node
	dev-lang/perl"
