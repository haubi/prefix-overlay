# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/URI/URI-1.36.ebuild,v 1.1 2008/04/29 14:53:44 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=GAAS

inherit perl-module

DESCRIPTION="A URI Perl Module"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="virtual/perl-MIME-Base64
	dev-lang/perl"

SRC_TEST=do

mydoc="rfc2396.txt"
