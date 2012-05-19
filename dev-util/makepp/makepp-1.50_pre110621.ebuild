# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/makepp/makepp-1.50_pre110621.ebuild,v 1.1 2011/08/07 20:48:25 vapier Exp $

EAPI="3"

inherit eutils

MY_PV=${PV/_pre/-}
MY_P="${PN}-${MY_PV}"
DESCRIPTION="GNU make replacement"
HOMEPAGE="http://makepp.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PV%_pre*}/${MY_P}.txz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/perl-5.6.0"

S=${WORKDIR}/${MY_P}

src_unpack() {
	ln -s "${DISTDIR}/${A}" ${P}.tar.xz
	unpack ./${P}.tar.xz
}

src_prepare() {
#	epatch "${FILESDIR}"/${P}-install.patch
	# remove ones which cause sandbox violations
#	rm makepp_tests/wildcard_repositories.test
	# default "all" rule is to run tests :x
	sed -i '/^all:/s:test::' config.pl || die
}

src_configure() {
	# not an autoconf configure script
	./configure \
		--prefix="${EPREFIX}"/usr \
		--bindir="${EPREFIX}"/usr/bin \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--mandir="${EPREFIX}"/usr/share/man \
		--datadir="${EPREFIX}"/usr/share/makepp \
		|| die "configure failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog README
}
