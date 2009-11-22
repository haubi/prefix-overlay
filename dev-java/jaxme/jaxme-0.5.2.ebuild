# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jaxme/jaxme-0.5.2.ebuild,v 1.4 2009/11/16 22:04:03 maekke Exp $

EAPI="2"

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2 eutils

MY_PN=ws-${PN}
MY_P=${MY_PN}-${PV}
DESCRIPTION="JaxMe 2 is an open source implementation of JAXB, the specification for Java/XML binding."
HOMEPAGE="http://ws.apache.org/jaxme/index.html"
SRC_URI="mirror://apache/ws/${PN}/source/${MY_P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

COMMON_DEP="dev-java/antlr:0[java]
	>=dev-java/xerces-2.7
	=dev-java/junit-3.8*
	>=dev-java/log4j-1.2.8
	dev-java/xmldb:0"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	dev-db/hsqldb:0
	${COMMON_DEP}"

S="${WORKDIR}/${MY_P}"

# We do it later
JAVA_PKG_BSFIX="off"

java_prepare() {
	cd "${S}/prerequisites"
	rm *.jar
	java-pkg_jarfrom antlr
	java-pkg_jarfrom junit
	java-pkg_jarfrom log4j log4j.jar log4j-1.2.8.jar
	java-pkg_jarfrom xerces-2
	java-pkg_jarfrom xmldb xmldb-api.jar xmldb-api-20021118.jar
	java-pkg_jarfrom xmldb xmldb-api-sdk.jar xmldb-api-sdk-20021118.jar
	java-pkg_jarfrom --build-only ant-core ant.jar ant-1.5.4.jar
	java-pkg_jarfrom --build-only ant-core ant.jar ant.jar
	# no linking to it, probably should be test only (FIXME)
	java-pkg_jarfrom --build-only hsqldb hsqldb.jar hsqldb-1.7.1.jar

	# Special case: jaxme uses ant/*.xml files, so rewriting them by hand
	# is better:
	cd "${S}"
	for i in build.xml ant/*.xml src/webapp/web.xml src/test/jaxb/build.xml; do
		java-ant_bsfix_one "${i}"
	done

	# Patch marshal classes to be abstract for build to succeed
	epatch "${FILESDIR}/${P}-fix_marshallers.patch"
}

EANT_BUILD_TARGET="all"
EANT_EXTRA_ARGS=""
EANT_TEST_ANT_TASKS="hsqldb"

src_compile() {
	use doc && EANT_EXTRA_ARGS+="-Dbuild.apidocs=dist/doc/api"

	java-pkg-2_src_compile
}

src_install() {
	pushd dist > /dev/null
	for jar in *.jar; do
		java-pkg_newjar ${jar} ${jar/-${PV}/}
	done
	popd > /dev/null

	dodoc NOTICE || die

	if use doc; then
		java-pkg_dojavadoc dist/doc/api
		dohtml -r src/documentation/manual
	fi
	use source && java-pkg_dosrc src/{pm,jaxme,js,api,webapp,xs}/*
}
