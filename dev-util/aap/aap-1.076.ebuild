# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/aap/aap-1.076.ebuild,v 1.6 2007/07/25 17:33:23 armin76 Exp $

EAPI="prefix"

IUSE="doc"

DESCRIPTION="Bram Moolenaar's super-make program"
HOMEPAGE="http://www.a-a-p.org/"
SRC_URI="mirror://sourceforge/a-a-p/${P}.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
DEPEND="app-arch/unzip"
RDEPEND=">=dev-lang/python-1.5"
S=${WORKDIR}/${PN}

src_unpack() {
	mkdir ${S} && cd ${S} && unzip -q ${DISTDIR}/${A} || die
}

src_install() {
	rm doc/*.sgml
	rm doc/*.pdf

	if use doc ; then
		dodir /usr/share/doc/${PF}/html
		cp -R doc/* ${ED}/usr/share/doc/${PF}/html
	fi
	rm doc/*.html
	rm -fr doc/images

	dodoc doc/*
	doman aap.1
	rm -rf doc aap.1

	# Move the remainder directly into the dest tree
	dodir /usr/share
	cd ${WORKDIR}
	mv aap ${ED}/usr/share

	# Create a symbolic link for the executable
	dodir /usr/bin
	ln -s ../share/aap/aap ${ED}/usr/bin/aap
}
