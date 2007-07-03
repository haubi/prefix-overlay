# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-WikiFormat/Text-WikiFormat-0.79.ebuild,v 1.1 2007/06/29 14:31:40 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Translate Wiki formatted text into other formats"
SRC_URI="mirror://cpan/authors/id/C/CH/CHROMATIC/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~chromatic/${P}/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND="dev-perl/URI
	virtual/perl-Scalar-List-Utils
		>=dev-perl/module-build-0.28
	dev-lang/perl"
IUSE=""

SRC_TEST="do"


