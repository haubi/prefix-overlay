# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/IO-Compress-Base/IO-Compress-Base-2.015.ebuild,v 1.2 2008/11/04 09:42:12 vapier Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS

inherit perl-module

DESCRIPTION="Base Class for IO::Compress modules"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND="virtual/perl-Scalar-List-Utils
	dev-lang/perl"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod )"

SRC_TEST="do"
