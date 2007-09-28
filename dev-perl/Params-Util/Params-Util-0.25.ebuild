# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Params-Util/Params-Util-0.25.ebuild,v 1.4 2007/08/09 15:09:06 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Utility functions to aid in parameter checking"
HOMEPAGE="http://search.cpan.org/search?module=Param-Util"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~sparc-solaris ~x86 ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=virtual/perl-Scalar-List-Utils-1.14
	dev-lang/perl"
