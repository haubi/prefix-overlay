# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/File-Spec/File-Spec-3.25.ebuild,v 1.4 2007/08/09 15:40:04 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

MY_P="PathTools-${PV}"

DESCRIPTION="Handling files and directories portably"
HOMEPAGE="http://search.cpan.org/~kwilliams/"
SRC_URI="mirror://cpan/authors/id/K/KW/KWILLIAMS/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""
SRC_TEST="do"

RDEPEND="dev-lang/perl
	dev-perl/ExtUtils-CBuilder"
DEPEND="${RDEPEND}
	dev-perl/module-build"

S=${WORKDIR}/${MY_P}

myconf='INSTALLDIRS=vendor'
