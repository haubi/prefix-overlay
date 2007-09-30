# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.4.0.ebuild,v 1.11 2007/08/25 14:07:48 vapier Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo/"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="examples"

RDEPEND=">=x11-libs/cairo-1.4.0"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PYTHON_MODNAME="cairo"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# don't run py-compile
	sed -i \
		-e '/if test -n "$$dlist"; then/,/else :; fi/d' \
		cairo/Makefile.in || die "sed in cairo/Makefile.in failed"
}

src_install() {
	distutils_src_install

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	dodoc AUTHORS NOTES README NEWS ChangeLog
}

src_test() {
	cd test
	PYTHONPATH="$(ls -d ${S}/build/lib.*)" "${python}" test.py || die "tests failed"
}
