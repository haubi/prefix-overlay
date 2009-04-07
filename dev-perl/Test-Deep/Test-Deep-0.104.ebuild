# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Deep/Test-Deep-0.104.ebuild,v 1.4 2009/04/06 15:44:58 armin76 Exp $

EAPI="prefix 2"

MODULE_AUTHOR=FDALY
inherit perl-module

DESCRIPTION="Test::Deep - Extremely flexible deep comparison"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

DEPEND="
	test? ( dev-perl/Test-NoWarnings
		dev-perl/Test-Tester )"
RDEPEND=""

SRC_TEST="do"
