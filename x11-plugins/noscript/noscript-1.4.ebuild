# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/noscript/noscript-1.4.ebuild,v 1.1 2008/02/21 17:12:36 armin76 Exp $

EAPI="prefix"

inherit mozextension multilib

DESCRIPTION="Firefox plugin to disable javascript"
HOMEPAGE="http://noscript.net/"
SRC_URI="http://software.informaction.com/data/releases/${P}.xpi"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux"
IUSE=""

RDEPEND="|| (
	>=www-client/mozilla-firefox-bin-1.5.0.7
	>=www-client/mozilla-firefox-1.5.0.7
)"
DEPEND="${RDEPEND}"

S=${WORKDIR}

src_unpack() {
	xpi_unpack "${P}".xpi
}

src_install() {
	declare MOZILLA_FIVE_HOME
	if has_version '>=www-client/mozilla-firefox-1.5.0.7'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/usr/$(get_libdir)/mozilla-firefox"
		xpi_install "${S}"/"${P}"
	fi
	if has_version '>=www-client/mozilla-firefox-bin-1.5.0.7'; then
		MOZILLA_FIVE_HOME="${EPREFIX}/opt/firefox"
		xpi_install "${S}"/"${P}"
	fi
}
