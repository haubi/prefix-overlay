# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/psycopg/psycopg-2.0.5.1.ebuild,v 1.3 2008/05/19 19:47:13 dev-zero Exp $

EAPI="prefix"

NEED_PYTHON=2.4

inherit eutils distutils

MY_P=${PN}2-${PV}

DESCRIPTION="PostgreSQL database adapter for Python."
SRC_URI="http://initd.org/pub/software/psycopg/${MY_P}.tar.gz"
HOMEPAGE="http://initd.org/projects/psycopg2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
LICENSE="GPL-2"
IUSE="debug doc examples"

DEPEND=">=virtual/postgresql-base-7.4"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	use debug && epatch "${FILESDIR}/${P}-debug.patch"

	# Fixes compilation issue in fbsd.
	epatch "${FILESDIR}/${P}-fbsd.patch"
	# ... and also fix it on Solaris (the same way)
	epatch "${FILESDIR}"/${P}-use-configure-or-die.patch
}

src_install() {
	DOCS="AUTHORS doc/HACKING doc/SUCCESS doc/TODO doc/async.txt"
	distutils_src_install

	insinto /usr/share/doc/${PF}
	use examples && doins -r examples

	cd doc
	use doc && dohtml -r .
}
