# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/maven-bin/maven-bin-2.0.8.ebuild,v 1.6 2008/03/28 22:56:12 maekke Exp $

inherit java-pkg-2 prefix

MY_PN=apache-${PN%%-bin}
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="mirror://apache/maven/binaries/${MY_P}-bin.tar.bz2"
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="2.0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

RDEPEND=">=virtual/jdk-1.4"

IUSE=""

S="${WORKDIR}/${MY_P}"

MAVEN=${PN}-${SLOT}
MAVEN_SHARE="/usr/share/${MAVEN}"

src_unpack() {
	unpack ${A}

	rm -v "${S}"/bin/*.bat || die

	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify bin/mvn
}

# TODO we should use jars from packages, instead of what is bundled
src_install() {
	dodir "${MAVEN_SHARE}"
	cp -Rp bin boot conf lib "${ED}/${MAVEN_SHARE}" || die "failed to copy"

	java-pkg_regjar "${ED}/${MAVEN_SHARE}"/lib/*.jar

	dodoc NOTICE.txt README.txt || die

	dodir /usr/bin
	dosym "${MAVEN_SHARE}/bin/mvn" /usr/bin/mvn
}
