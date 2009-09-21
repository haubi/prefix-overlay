# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/xfce4-meta/xfce4-meta-4.6.1.ebuild,v 1.3 2009/09/13 08:11:14 ssuominen Exp $

EAPI=2

DESCRIPTION="Xfce4 Desktop Environment (meta package)"
HOMEPAGE="http://www.xfce.org/"
SRC_URI=""

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="minimal +session"

RDEPEND="x11-themes/gtk-engines-xfce
	>=xfce-base/xfce4-panel-${PV}
	>=xfce-base/xfwm4-${PV}
	>=xfce-base/xfce-utils-${PV}
	>=xfce-base/xfdesktop-${PV}
	>=xfce-base/xfce4-settings-${PV}
	x11-themes/hicolor-icon-theme
	!minimal? ( media-fonts/dejavu
		x11-themes/xfce4-icon-theme )
	session? ( >=xfce-base/xfce4-session-${PV} )"
