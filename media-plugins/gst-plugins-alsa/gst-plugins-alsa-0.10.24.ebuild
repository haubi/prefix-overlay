# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-alsa/gst-plugins-alsa-0.10.24.ebuild,v 1.5 2009/11/18 21:49:04 fauli Exp $

inherit gst-plugins-base

KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=media-libs/gst-plugins-base-0.10.23
	>=media-libs/alsa-lib-0.9.1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
