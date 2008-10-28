# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/List-MoreUtils/List-MoreUtils-0.22.ebuild,v 1.4 2008/07/22 19:25:20 corsair Exp $

EAPI="prefix"

MODULE_AUTHOR=VPARSEVAL
inherit perl-module

DESCRIPTION="Provide the missing functionality from List::Util"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
