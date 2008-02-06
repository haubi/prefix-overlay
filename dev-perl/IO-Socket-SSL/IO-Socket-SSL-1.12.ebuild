# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Socket-SSL/IO-Socket-SSL-1.12.ebuild,v 1.6 2008/02/05 10:20:59 corsair Exp $

EAPI="prefix"

inherit perl-module versionator

DESCRIPTION="Nearly transparent SSL encapsulation for IO::Socket::INET"
HOMEPAGE="http://search.cpan.org/~sullr/IO-Socket-SSL/"
SRC_URI="mirror://cpan/authors/id/S/SU/SULLR/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=dev-perl/Net-SSLeay-1.21
	dev-lang/perl"

# Tests have been fixed upstream to attempt to use a random port. Adding tests
# back in for now.
SRC_TEST="do"
