# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-screenshooter/xfce4-screenshooter-1.3.1.ebuild,v 1.1 2008/08/21 19:39:45 angelos Exp $

EAPI="prefix"

inherit eutils xfce44

xfce44
xfce44_gzipped

DESCRIPTION="Xfce4 panel screenshooter plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
