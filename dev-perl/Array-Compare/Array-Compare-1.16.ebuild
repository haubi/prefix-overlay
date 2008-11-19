# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Array-Compare/Array-Compare-1.16.ebuild,v 1.2 2008/11/18 14:24:08 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=DAVECROSS
inherit perl-module

DESCRIPTION="Perl extension for comparing arrays."

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

SRC_TEST="do"

RDEPEND="dev-lang/perl"
DEPEND=">=virtual/perl-Module-Build-0.28
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )
	${RDEPEND}"
