# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/sun-javamail/sun-javamail-1.4.1.ebuild,v 1.5 2008/03/11 15:16:59 ranger Exp $

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="A Java-based framework to build multiplatform mail and messaging applications."
HOMEPAGE="http://java.sun.com/products/javamail/index.html"
# CVS:
# View: https://glassfish.dev.java.net/source/browse/glassfish/mail/?only_with_tag=JAVAMAIL-1_4
# How-To: https://glassfish.dev.java.net/servlets/ProjectSource

# Remember to pray that bootstrap HEAD works
#cvs -d:pserver:guest@cvs.dev.java.net:/cvs export -r <tag> glassfish/mail
#cvs -d:pserver:guest@cvs.dev.java.net:/cvs export -r HEAD glassfish/bootstrap
#rm -v glassfish/mail/*.jar
#tar cvjf ${P}.tar.bz glassfish
#upload

SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="CDDL"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

COMMON_DEP="dev-java/sun-jaf"
DEPEND=">=virtual/jdk-1.5
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/glassfish/mail"

JAVA_PKG_WANT_SOURCE="1.4"
JAVA_PKG_WANT_TARGET="1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	java-pkg_jar-from sun-jaf
}

EANT_DOC_TARGET="docs"
EANT_EXTRA_ARGS="-Djavaee.jar=activation.jar"

src_install() {
	java-pkg_dojar build/release/mail.jar
	use doc && java-pkg_dojavadoc build/release/docs/javadocs
	use source && java-pkg_dosrc src/java
}
