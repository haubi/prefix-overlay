# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Params-Util/Params-Util-0.30.ebuild,v 1.4 2008/01/13 21:42:00 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Utility functions to aid in parameter checking"
HOMEPAGE="http://search.cpan.org/search?module=Param-Util"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND=">=virtual/perl-Scalar-List-Utils-1.14
	dev-lang/perl"
