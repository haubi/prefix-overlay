# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libcroco/libcroco-0.6.1.ebuild,v 1.12 2007/05/27 00:56:47 kumba Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="Generic Cascading Style Sheet (CSS) parsing and manipulation toolkit"
HOMEPAGE="http://www.freespiders.org/projects/libcroco/"

LICENSE="LGPL-2"
SLOT="0.6"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE=""

RDEPEND=">=dev-libs/glib-2
	>=dev-libs/libxml2-2.4.23"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"
