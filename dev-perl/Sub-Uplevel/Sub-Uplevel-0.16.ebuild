# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Sub-Uplevel/Sub-Uplevel-0.16.ebuild,v 1.1 2007/10/19 20:58:49 ian Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="apparently run a function in a higher stack frame"
HOMEPAGE="http://search.cpan.org/~mschwern/${P}/"
SRC_URI="mirror://cpan/authors/id/D/DA/DAGOLDEN/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/module-build
		dev-lang/perl"
RDEPEND="dev-lang/perl"
