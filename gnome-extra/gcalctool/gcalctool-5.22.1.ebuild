# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/gnome-extra/gcalctool/gcalctool-5.22.1.ebuild,v 1.1 2008/04/10 22:25:18 eva Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="A calculator application for GNOME"
HOMEPAGE="http://calctool.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.11.6
	>=dev-libs/glib-2
	>=dev-libs/atk-1.5
	>=gnome-base/gconf-2
	gnome-base/libglade
	!<gnome-extra/gnome-utils-2.3"
DEPEND="${RDEPEND}
	sys-devel/gettext
	app-text/scrollkeeper
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	>=app-text/gnome-doc-utils-0.3.2"

DOCS="AUTHORS ChangeLog* MAINTAINERS NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	echo "gcalctool/ce_parser.tab.c" >> po/POTFILES.in
	echo "gcalctool/lr_parser.tab.c" >> po/POTFILES.in
}
