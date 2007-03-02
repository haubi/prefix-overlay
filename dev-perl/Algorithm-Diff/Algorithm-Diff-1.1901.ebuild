# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Algorithm-Diff/Algorithm-Diff-1.1901.ebuild,v 1.13 2007/02/06 14:37:01 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Algorithm::Diff - Compute intelligent differences between two files / lists"
HOMEPAGE="http://search.cpan.org/~tyemq/"
SRC_URI="mirror://cpan/authors/id/T/TY/TYEMQ/${P}.zip"
LICENSE="|| ( Artistic GPL-2 )"
IUSE=""
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND="app-arch/unzip
	dev-lang/perl"

SRC_TEST="do"
