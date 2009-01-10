# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Socket-SSL/IO-Socket-SSL-1.19.ebuild,v 1.2 2009/01/09 23:03:35 josejx Exp $

EAPI="prefix"

MODULE_AUTHOR=SULLR
inherit perl-module

DESCRIPTION="Nearly transparent SSL encapsulation for IO::Socket::INET"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	>=dev-perl/Net-SSLeay-1.33
	virtual/perl-Scalar-List-Utils
	dev-perl/Net-LibIDN"

SRC_TEST="do"
