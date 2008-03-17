# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-NamespaceSupport/XML-NamespaceSupport-1.09.ebuild,v 1.17 2007/01/19 17:37:06 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl module that offers a simple to process namespaced XML names"
HOMEPAGE="http://search.cpan.org/~rberjon/"
SRC_URI="mirror://cpan/authors/id/R/RB/RBERJON/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-libs/libxml2-2.4.1
	dev-lang/perl"

SRC_TEST="do"
