# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gcalctool/gcalctool-5.24.3.1.ebuild,v 1.3 2009/03/06 15:45:57 ranger Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="A calculator application for GNOME"
HOMEPAGE="http://calctool.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=x11-libs/gtk+-2.14.0
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
