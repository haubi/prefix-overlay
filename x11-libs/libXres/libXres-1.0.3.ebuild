# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libXres/libXres-1.0.3.ebuild,v 1.1 2006/12/16 16:55:28 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XRes library"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/xproto"
DEPEND="${RDEPEND}
	x11-proto/resourceproto"
