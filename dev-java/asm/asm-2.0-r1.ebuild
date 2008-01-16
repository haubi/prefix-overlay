# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/asm/asm-2.0-r1.ebuild,v 1.6 2008/01/12 16:33:51 ranger Exp $

EAPI="prefix"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Bytecode manipulation framework for Java"
HOMEPAGE="http://asm.objectweb.org"
SRC_URI="http://download.forge.objectweb.org/${PN}/${P}.tar.gz"
LICENSE="BSD"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	dev-java/ant-owanttask
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.3"
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd ${S}
	echo "objectweb.ant.tasks.path ${EPREFIX}/usr/share/ant-owanttask/lib/ow_util_ant_tasks.jar" \
		>> build.properties
}

src_compile() {
	eant jar $(use_doc jdoc)
}

src_install() {
	for x in output/dist/lib/*.jar ; do
		java-pkg_newjar ${x} $(basename ${x/-${PV}})
	done
	use doc && java-pkg_dohtml -r output/dist/doc/javadoc/user/*
	use source && java-pkg_dosrc src/*
}
