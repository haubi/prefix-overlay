# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/formencode/formencode-1.0.ebuild,v 1.1 2008/03/23 15:13:17 chtekk Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

MY_PN="FormEncode"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HTML form validation, generation and conversion package."
HOMEPAGE="http://formencode.org/"
SRC_URI="http://cheeseshop.python.org/packages/source/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"
LICENSE="PSF-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="doc"

DEPEND="dev-python/setuptools"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install

	if use doc ; then
		cd "${S}"
		dodoc docs/*.txt

		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
