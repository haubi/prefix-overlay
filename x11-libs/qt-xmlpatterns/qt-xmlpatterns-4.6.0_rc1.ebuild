# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.6.0_rc1.ebuild,v 1.1 2009/11/18 20:48:56 wired Exp $

EAPI=2
inherit qt4-build

DESCRIPTION="The patternist module for the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=]"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/xmlpatterns"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/QtCore
include/QtXml
include/QtNetwork
include/QtXmlPatterns
src/network/
src/xml/
src/corelib/"

QCONFIG_ADD="xmlpatterns"
QCONFIG_DEFINE="QT_XMLPATTERNS"

src_configure() {
	myconf="${myconf} -xmlpatterns"
	qt4-build_src_configure
}