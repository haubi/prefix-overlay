# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Package-Constants/Package-Constants-0.01.ebuild,v 1.8 2008/10/27 16:32:16 aballier Exp $

EAPI="prefix"

MODULE_AUTHOR=KANE
inherit perl-module

DESCRIPTION="List all constants declared in a package"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST=do
