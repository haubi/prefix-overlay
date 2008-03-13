# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/mozilla-launcher/mozilla-launcher-1.59.ebuild,v 1.1 2008/03/12 18:42:50 armin76 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Script that launches mozilla or firefox"
HOMEPAGE="http://sources.gentoo.org/viewcvs.py/gentoo-src/mozilla-launcher/"
SRC_URI="mirror://gentoo/${P}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="x11-apps/xdpyinfo"

S=${WORKDIR}

src_install() {
	exeinto /usr/libexec
	newexe ${P} mozilla-launcher || die
	sed -i -e "1s|/bin/bash|${EPREFIX}/bin/bash|" \
		-e "/^PATH=/s|=.*:\\\$PATH|=${EPREFIX}/usr/bin:${EPREFIX}/bin:${EPREFIX}/usr/X11R6/bin:\$PATH|" \
		-e "s|/usr/bin/xtoolwait|${EPREFIX}/usr/bin/xtoolwait|" \
		-e "/MOZILLA_LIBDIR:-/s|/usr/lib|${EPREFIX}/usr/lib|" \
		-e "/MOZILLA_LIBDIR:-/s|/opt|${EPREFIX}/opt|" \
		-e "/MOZ_PLUGIN_PATH=/s|/usr/lib|${EPREFIX}/usr/lib|" \
		"${ED}"/usr/libexec/mozilla-launcher || die
}

pkg_postinst() {
	local f

	find "${EROOT}/usr/bin" -maxdepth 1 -type l | \
	while read f; do
		[[ $(readlink ${f}) == mozilla-launcher ]] || continue
		einfo "Updating ${f} symlink to /usr/libexec/mozilla-launcher"
		ln -sfn "${EPREFIX}"/usr/libexec/mozilla-launcher ${f}
	done
}
