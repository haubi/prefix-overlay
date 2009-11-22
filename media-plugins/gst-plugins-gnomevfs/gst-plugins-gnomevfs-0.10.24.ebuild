# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-gnomevfs/gst-plugins-gnomevfs-0.10.24.ebuild,v 1.5 2009/11/18 21:53:58 fauli Exp $

inherit gst-plugins-base

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.23
	>=gnome-base/gnome-vfs-2"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

GST_PLUGINS_BUILD="gnome_vfs"
