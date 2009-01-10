# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboop/liboop-1.0.ebuild,v 1.11 2009/01/08 18:16:44 jer Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="low-level event loop management library for POSIX-based operating systems"
HOMEPAGE="http://liboop.ofb.net/"
SRC_URI="http://download.ofb.net/liboop/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="adns gnome tcl readline libwww"

DEPEND="adns? ( net-libs/adns )
	gnome? ( dev-libs/glib )
	tcl? ( dev-lang/tcl )
	readline? ( sys-libs/readline )
	libwww? ( net-libs/libwww )"

src_compile() {
	econf \
		`use_with adns` \
		`use_with gnome` \
		`use_with tcl tcltk` \
		`use_with readline` \
		`use_with libwww` \
		|| die
	emake -j1 || die
}

src_install() {
	emake install DESTDIR=${D} || die
}
