# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Tester/Test-Tester-0.107.ebuild,v 1.5 2008/12/20 14:57:57 nixnut Exp $

EAPI="prefix"

MODULE_AUTHOR=FDALY
inherit perl-module

DESCRIPTION="Ease testing test modules built with Test::Builder"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
