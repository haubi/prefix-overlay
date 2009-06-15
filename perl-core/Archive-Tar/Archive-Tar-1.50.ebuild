# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Archive-Tar/Archive-Tar-1.50.ebuild,v 1.1 2009/06/12 16:33:37 tove Exp $

MODULE_AUTHOR=KANE
inherit perl-module

DESCRIPTION="A Perl module for creation and manipulation of tar files"

SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=virtual/perl-IO-Zlib-1.01
	virtual/perl-IO-Compress
	perl-core/Package-Constants
	dev-lang/perl"
#	dev-perl/IO-String

SRC_TEST="do"
