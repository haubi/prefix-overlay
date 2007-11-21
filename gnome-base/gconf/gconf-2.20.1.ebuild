# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gconf/gconf-2.20.1.ebuild,v 1.2 2007/11/20 13:43:07 drac Exp $

EAPI="prefix"

inherit gnome2

MY_PN=GConf
MY_P=${MY_PN}-${PV}
PVP=(${PV//[-\._]/ })

DESCRIPTION="Gnome Configuration System and Daemon"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="mirror://gnome/sources/${MY_PN}/${PVP[0]}.${PVP[1]}/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.10
		 >=x11-libs/gtk+-2.8.16
		 >=gnome-base/orbit-2.4
		 >=dev-libs/libxml2-2"
DEPEND="${RDEPEND}
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.9
		doc? ( >=dev-util/gtk-doc-1 )"

# FIXME : consider merging the tree (?)
DOCS="AUTHORS ChangeLog NEWS README TODO"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	G2CONF="${G2CONF} --enable-gtk $(use_enable debug)"
	kill_gconf
}

src_install() {
	gnome2_src_install

	# hack hack
	dodir /etc/gconf/gconf.xml.mandatory
	dodir /etc/gconf/gconf.xml.defaults
	touch "${ED}"/etc/gconf/gconf.xml.mandatory/.keep${SLOT}
	touch "${ED}"/etc/gconf/gconf.xml.defaults/.keep${SLOT}

	echo 'CONFIG_PROTECT_MASK="/etc/gconf"' > 50gconf
	doenvd 50gconf || die
	dodir /root/.gconfd
}

pkg_preinst() {
	kill_gconf
}

pkg_postinst() {
	kill_gconf

	#change the permissions to avoid some gconf bugs
	einfo "changing permissions for gconf dirs"
	find  /etc/gconf/ -type d -exec chmod ugo+rx "{}" \;

	einfo "changing permissions for gconf files"
	find  /etc/gconf/ -type f -exec chmod ugo+r "{}" \;
}

kill_gconf() {
	# this function will kill all running gconfd that could be causing troubles
	if [ -x "${EPREFIX}"/usr/bin/gconftool ]
	then
		"${EPREFIX}"/usr/bin/gconftool --shutdown
	fi
	if [ -x "${EPREFIX}"/usr/bin/gconftool-1 ]
	then
		"${EPREFIX}"/usr/bin/gconftool-1 --shutdown
	fi

	# and for gconf 2
	if [ -x "${EPREFIX}"/usr/bin/gconftool-2 ]
	then
		"${EPREFIX}"/usr/bin/gconftool-2 --shutdown
	fi
	return 0
}
