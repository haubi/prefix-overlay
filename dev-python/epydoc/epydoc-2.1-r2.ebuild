# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/epydoc/epydoc-2.1-r2.ebuild,v 1.17 2008/01/20 23:04:50 lucass Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="tool for generating API documentation for Python modules, based on their docstrings"
HOMEPAGE="http://epydoc.sourceforge.net/"
SRC_URI="mirror://sourceforge/epydoc/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc pdf"

RDEPEND="pdf? ( virtual/tetex )"

src_install() {
	distutils_src_install

	doman "${S}"/man/*
	use doc && dohtml -r "${S}"/doc/*
}
