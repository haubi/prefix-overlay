# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-sound/audacious/audacious-1.5.0.ebuild,v 1.1 2008/03/14 01:23:20 chainsaw Exp $

EAPI="prefix"

inherit eutils

MY_P="${P/_/-}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Audacious Player - Your music, your way, no exceptions"
HOMEPAGE="http://audacious-media-player.org/"
SRC_URI="http://distfiles.atheme.org/${MY_P}.tgz
	 mirror://gentoo/gentoo_ice-xmms-0.2.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="altivec chardet nls libsamplerate sse2"

RDEPEND=">=dev-libs/dbus-glib-0.60
	libsamplerate? ( media-libs/libsamplerate )
	>=dev-libs/libmcs-0.7.0
	>=dev-libs/libmowgli-0.6.1
	dev-libs/libxml2
	>=gnome-base/libglade-2.3.1
	>=x11-libs/gtk+-2.10
	>=dev-libs/glib-2.14"

DEPEND="${RDEPEND}
	!media-plugins/audacious-plugins-ugly
	>=dev-util/pkgconfig-0.9.0
	nls? ( dev-util/intltool )"

PDEPEND=">=media-plugins/audacious-plugins-1.5.0"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	# D-Bus is a mandatory dependency, remote control,
	# session management and some plugins depend on this.
	# Building without D-Bus is *unsupported* and a USE-flag
	# will not be added due to the bug reports that will result.
	# Bugs #197894, #199069, #207330, #208606
	econf \
		--enable-dbus \
		$(use_enable altivec) \
		$(use_enable chardet) \
		$(use_enable nls) \
		$(use_enable sse2) \
		$(use_enable libsamplerate samplerate) \
		|| die

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README

	# Gentoo_ice skin installation; bug #109772
	insinto /usr/share/audacious/Skins/gentoo_ice
	doins "${WORKDIR}"/gentoo_ice/*
	docinto gentoo_ice
	dodoc "${WORKDIR}"/README
}

pkg_postinst() {
	elog "Note that you need to recompile *all* third-party plugins for Audacious 1.5"
	elog "Plugins compiled against 1.3 or 1.4 will not be loaded."
}
