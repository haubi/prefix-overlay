# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-Base/Test-Base-0.55.ebuild,v 1.1 2008/12/08 02:40:32 robbat2 Exp $

EAPI="prefix"

MODULE_AUTHOR=INGY
inherit perl-module

DESCRIPTION="A Data Driven Testing Framework"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=virtual/perl-Test-Simple-0.62
		>=dev-perl/Spiffy-0.30
		>=dev-lang/perl-5.6.1"
