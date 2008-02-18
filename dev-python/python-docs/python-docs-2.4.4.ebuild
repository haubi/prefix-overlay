# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/python-docs/python-docs-2.4.4.ebuild,v 1.13 2007/06/26 16:22:20 vapier Exp $

EAPI="prefix"

DESCRIPTION="HTML documentation for Python"
HOMEPAGE="http://www.python.org/doc/${PV}/"
SRC_URI="http://www.python.org/ftp/python/doc/${PV}/html-${PV}.tar.bz2
http://www.python.org/ftp/python/doc/${PV}/info-${PV}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.4"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}

src_unpack() {
	unpack html-${PV}.tar.bz2
	mkdir ${S}/info
	cd ${S}/info
	unpack info-${PV}.tar.bz2
	rm -f README python.dir
}

src_install() {
	docinto html
	cp -R ${S}/Python-Docs-${PV}/* ${ED}/usr/share/doc/${PF}/html

	insinto /usr/share/info
	doins ${S}/info/*
}

pkg_preinst() {
	dodir /etc/env.d
	echo "PYTHONDOCS=${EPREFIX}/usr/share/doc/${PF}/html/lib" > ${ED}/etc/env.d/50python-docs
}
