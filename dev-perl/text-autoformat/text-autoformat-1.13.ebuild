# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/text-autoformat/text-autoformat-1.13.ebuild,v 1.13 2007/04/16 07:19:21 corsair Exp $

EAPI="prefix"

inherit perl-module

MY_P=Text-Autoformat-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Automatic text wrapping and reformatting"
SRC_URI="mirror://cpan/authors/id/D/DC/DCONWAY/${MY_P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~dconway/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-perl/text-reform-1.11
	dev-lang/perl"
