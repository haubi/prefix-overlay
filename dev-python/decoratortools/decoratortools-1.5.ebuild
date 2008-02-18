# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/decoratortools/decoratortools-1.5.ebuild,v 1.3 2007/12/31 16:26:32 josejx Exp $

EAPI="prefix"

inherit distutils

MY_PN="DecoratorTools"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Use class and function decorators - even in Python 2.3 - now with source debugging for generated code"
HOMEPAGE="http://cheeseshop.python.org/pypi/DecoratorTools"
SRC_URI="http://cheeseshop.python.org/packages/source/D/${MY_PN}/${MY_P}.zip"

LICENSE="|| ( PSF-2.4 ZPL )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="app-arch/unzip
	>=dev-python/setuptools-0.6_rc6"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_test() {
	"${python}" setup.py test || die "Test failed."
}
