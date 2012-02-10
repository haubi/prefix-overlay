# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/vte/vte-0.30.1-r3.ebuild,v 1.1 2012/01/30 17:26:59 tetromino Exp $

EAPI="4"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2 autotools

DESCRIPTION="GNOME terminal widget"
HOMEPAGE="http://git.gnome.org/browse/vte"

LICENSE="LGPL-2"
SLOT="2.90"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc glade +introspection"

PDEPEND="x11-libs/gnome-pty-helper"
RDEPEND=">=dev-libs/glib-2.26:2
	>=x11-libs/gtk+-3.1.9:3[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXft

	glade? ( >=dev-util/glade-3.9:3.10 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	sys-devel/gettext
	doc? ( >=dev-util/gtk-doc-1.13 )"

pkg_setup() {
	# Python bindings are via gobject-introspection
	# Ex: from gi.repository import Vte
	# Do not disable gnome-pty-helper, bug #401389
	G2CONF="${G2CONF}
		--disable-deprecation
		--disable-maintainer-mode
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)"

	if [[ ${CHOST} == *-interix* ]]; then
		G2CONF="${G2CONF} --disable-Bsymbolic"

		# interix stropts.h is empty...
		export ac_cv_header_stropts_h=no
	fi

	DOCS="AUTHORS ChangeLog HACKING NEWS README"
}

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=663779
	epatch "${FILESDIR}/${PN}-0.30.1-alt-meta.patch"
	# https://bugzilla.gnome.org/show_bug.cgi?id=652290
	epatch "${FILESDIR}"/${PN}-0.26.2-interix.patch

	eautoreconf
	gnome2_src_prepare
}

src_install() {
	gnome2_src_install
	rm -v "${ED}usr/libexec/gnome-pty-helper" || die
}
