# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Error/Error-0.17.015.ebuild,v 1.2 2008/11/18 14:52:26 tove Exp $

inherit versionator perl-module

MY_PV="$(delete_version_separator 2)"
MY_P="${PN}-${MY_PV}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Error/exception handling in an OO-ish way"
HOMEPAGE="http://search.cpan.org/dist/Error/"
SRC_URI="mirror://cpan/authors/id/S/SH/SHLOMIF/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? ( >=dev-perl/Test-Pod-1.14
		>=dev-perl/Test-Pod-Coverage-1.04 )"

SRC_TEST="do"
