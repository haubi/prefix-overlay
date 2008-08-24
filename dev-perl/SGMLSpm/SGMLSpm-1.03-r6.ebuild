# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/SGMLSpm/SGMLSpm-1.03-r6.ebuild,v 1.1 2008/08/23 15:55:05 tove Exp $

EAPI="prefix"

inherit eutils perl-module

MY_P="${P}ii"
S=${WORKDIR}/${PN}

DESCRIPTION="Perl library for parsing the output of nsgmls"
HOMEPAGE="http://search.cpan.org/author/DMEGG/SGMLSpm-1.03ii/"
SRC_URI="mirror://cpan/authors/id/D/DM/DMEGG/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND="dev-lang/perl"
mydoc="TODO BUGS"

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}"/Makefile.PL "${S}"/Makefile.PL
	epatch "${FILESDIR}"/sgmlspl.patch
	mv "${S}"/sgmlspl{.pl,}

	sed -i \
		-e "s:PERL = :PERL = ${EPREFIX}:" \
		-e "s:PERL5DIR = \${D}:PERL5DIR = ${ED}:" \
		-e "s:BINDIR = \${D}:BINDIR = ${ED}:" \
		-e "s:HTMLDIR = \${D}:HTMLDIR = ${ED}:" Makefile
}

src_install () {
	dodir /usr/bin
	dodir /usr/lib/${package}/vendor_perl/${version}
	dodir /usr/share/SGMLS
	dodoc BUGS ChangeLog README TODO
	make install -f "${S}"/Makefile || die
	make docs -f "${S}"/Makefile || die
#	cd ${ED}/usr/lib/${package}/vendor_perl/${version}
}
