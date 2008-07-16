# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-chdir/File-chdir-0.1002.ebuild,v 1.3 2008/07/15 19:22:36 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="An alternative to File::Spec and CWD"
HOMEPAGE="http://search.cpan.org/~dagolden/"
SRC_URI="mirror://cpan/authors/id/D/DA/DAGOLDEN/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

RDEPEND=">=virtual/perl-File-Spec-3.27
	dev-lang/perl"
DEPEND="${RDEPEND}
	dev-perl/module-build"
