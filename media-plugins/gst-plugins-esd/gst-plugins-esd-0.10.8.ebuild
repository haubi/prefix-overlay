# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-esd/gst-plugins-esd-0.10.8.ebuild,v 1.9 2009/04/05 17:47:28 armin76 Exp $

EAPI="prefix"

inherit gst-plugins-good

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=media-sound/esound-0.2.8
	>=media-libs/gstreamer-0.10.18
	>=media-libs/gst-plugins-base-0.10.18"
