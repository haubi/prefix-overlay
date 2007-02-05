# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libfontenc/libfontenc-1.0.4.ebuild,v 1.1 2006/12/16 16:59:30 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org fontenc library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"

CONFIGURE_OPTIONS="--with-encodingsdir=/usr/share/fonts/encodings"
