# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime-TimeZone/DateTime-TimeZone-0.82.ebuild,v 1.1 2008/10/20 16:40:30 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=DROLSKY
inherit perl-module

DESCRIPTION="Time zone object base class and factory"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""
SRC_TEST="do"

RDEPEND=">=dev-perl/Params-Validate-0.72
	>=dev-perl/Class-Singleton-1.03
	dev-lang/perl"
DEPEND="${RDEPEND}
	>=dev-perl/module-build-0.28"
