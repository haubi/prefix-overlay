# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Shell-EnvImporter/Shell-EnvImporter-1.06.ebuild,v 1.1 2008/12/08 02:37:35 robbat2 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl extension for importing environment variable changes from external commands or shell scripts"
HOMEPAGE="http://search.cpan.org/~dfaraldo"
SRC_URI="mirror://cpan/authors/id/D/DF/DFARALDO/${P}.tar.gz"

IUSE=""

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND=">=dev-perl/Class-MethodMaker-2
		dev-lang/perl"
