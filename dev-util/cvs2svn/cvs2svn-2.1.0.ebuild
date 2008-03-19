# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cvs2svn/cvs2svn-2.1.0.ebuild,v 1.1 2008/03/18 21:58:52 cardoe Exp $

EAPI="prefix"

inherit distutils

FILEVER="41596"

DESCRIPTION="Convert a CVS repository to a Subversion repository"
HOMEPAGE="http://cvs2svn.tigris.org/"
SRC_URI="http://cvs2svn.tigris.org/files/documents/1462/${FILEVER}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lang/python
		>=dev-util/subversion-1.0.9"
RDEPEND="${DEPEND}
		app-text/rcs"

src_install() {
	distutils_src_install
	insinto "/usr/share/${PN}"
	doins -r contrib cvs2svn-example.options {profile-repos,show-db,verify-cvs2svn}.py
	doman cvs2svn.1
}

src_test() {
	export LC_ALL=C
	python run-tests.py || die "tests failed"
}
pkg_postinst() {
	elog "Additional scripts and examples have been installed to:"
	elog "  ${EROOT}usr/share/${PN}/"
}

src_test() {
	# Need this because subversion is localized, but the tests aren't
	export LC_ALL=C
	python run-tests.py || die "tests failed"
}
