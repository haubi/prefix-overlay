# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jrexx/jrexx-1.1.1-r1.ebuild,v 1.7 2007/10/24 05:23:02 wltjr Exp $

EAPI="prefix"

inherit java-pkg-2

DESCRIPTION="Regular expression API for textual pattern matching based on the finite state automaton theory."
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"
HOMEPAGE="http://www.karneim.com/jrexx/"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		source? ( app-arch/zip )"
IUSE="doc source"
JAVA_PKG_FILTER_COMPILER="jikes"
S=${WORKDIR}

src_compile() {
	mkdir build

	cd src
	ejavac -nowarn -d "${S}"/build $(find . -name "*.java") \
		|| die "Failed to compile ${i}"

	if use doc ; then
		mkdir "${S}"/javadoc
		javadoc -d "${S}"/javadoc $(find * -type d | tr '/' '.') \
			|| die "failed to build javadocs"
	fi

	cd ..
	jar cf ${PN}.jar -C build com || die "failed to create jar"
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/*
}
