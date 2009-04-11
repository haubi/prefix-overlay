# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/servletapi/servletapi-2.2-r3.ebuild,v 1.11 2008/01/06 19:04:55 caster Exp $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Servlet API 2.2 from jakarta.apache.org"
HOMEPAGE="http://jakarta.apache.org/"
SRC_URI="mirror://gentoo/${P}-20021101.tar.gz"
DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.4"
RDEPEND=">=virtual/jre-1.3"
LICENSE="Apache-1.1"
SLOT="2.2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="doc"
S="${WORKDIR}/jakarta-servletapi-src"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i 's/compile,javadoc/compile/' build.xml || die "sed failed"
}

EANT_BUILD_TARGET="all"

src_install() {
	java-pkg_dojar ../dist/servletapi/lib/servlet.jar

	dodoc README || die
	use doc && java-pkg_dojavadoc ../build/servletapi/docs/api
	use source && java-pkg_dosrc src/share/javax
}
