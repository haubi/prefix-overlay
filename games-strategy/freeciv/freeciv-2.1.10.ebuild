# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/freeciv/freeciv-2.1.10.ebuild,v 1.1 2010/01/11 13:26:55 tupone Exp $
EAPI=2

inherit eutils gnome2-utils games

DESCRIPTION="multiplayer strategy game (Civilization Clone)"
HOMEPAGE="http://www.freeciv.org/"
SRC_URI="mirror://sourceforge/freeciv/${P}.tar.bz2
	!dedicated? (
		sdl? (
			ftp://ftp.freeciv.org/freeciv/contrib/audio/soundsets/stdsounds3.tar.gz )
	)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="auth dedicated gtk nls readline sdl Xaw3d"

RDEPEND="readline? ( sys-libs/readline )
	auth? ( virtual/mysql )
	!dedicated? (
		nls? ( virtual/libintl )
		gtk? ( >=x11-libs/gtk+-2 )
		!gtk? (
			Xaw3d? ( x11-libs/Xaw3d )
			!Xaw3d? (
				sdl? (
					media-libs/sdl-image
					media-libs/freetype
				)
				!sdl? ( x11-libs/libXaw )
			)
		)
		media-libs/libpng
		sdl? ( media-libs/sdl-mixer )
	)"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	!dedicated? (
		gtk? ( dev-util/pkgconfig )
		x11-proto/xextproto
	)"

pkg_setup() {
	games_pkg_setup
	if ! use dedicated ; then
		if use gtk ; then
			einfo "The Freeciv Client will be built with the GTK+-2 toolkit"
		elif use Xaw3d ; then
			einfo "The Freeciv Client will be built with the Xaw3d toolkit"
		elif use sdl ; then
			einfo "The Freeciv Client will be built with the SDL toolkit"
		else
			einfo "The Freeciv Client will be built with the Xaw toolkit"
		fi
		if ! use sdl ; then
			ewarn
			ewarn "To enable sound support in civclient, you must enable"
			ewarn "this USE flags: sdl"
			ewarn
		fi
	fi
}

src_prepare() {
	# install locales in /usr/share/locale
	sed -i \
		-e 's:^\(localedir = \).*:\1/usr/share/locale:' \
		intl/Makefile.in po/Makefile.in.in \
		|| die "sed failed"
	sed -i \
		-e 's:$datadir/locale:/usr/share/locale:' \
		configure \
		|| die "sed failed"

	# change .desktop category so it's freedesktop complient
	sed -i \
		-e '/Icon/ s:\.png::' \
		bootstrap/freeciv.desktop.in \
		|| die "sed failed"
	# install the .desktop in /usr/share/applications
	# install the icons in /usr/share/pixmaps
	sed -i \
		-e 's:^\(desktopfiledir = \).*:\1/usr/share/applications:' \
		-e 's:^\(icon[0-9]*dir = \)$(prefix)\(.*\):\1/usr\2:' \
		-e 's:^\(icon[0-9]*dir = \)$(datadir)\(.*\):\1/usr/share\2:' \
		client/Makefile.in \
		server/Makefile.in \
		data/Makefile.in \
		data/icons/Makefile.in \
		|| die "sed failed"

	# and now install it all under ${EPREFIX}
	sed -i \
		-e "s:/usr:${EPREFIX}/usr:" \
		intl/Makefile.in po/Makefile.in.in \
		configure \
		client/Makefile.in \
		server/Makefile.in \
		data/Makefile.in \
		data/icons/Makefile.in \
		|| die "sed failed"

	# remove civclient manpage if dedicated server
	if use dedicated ; then
		sed -i \
			-e '/man_MANS = /s:civclient.6::' \
			doc/man/Makefile.in \
			|| die "sed failed"
	fi
}

src_configure() {
	local mysoundconf
	local myclient

	if use dedicated ; then
		mysoundconf="--disable-sdl-mixer"
		myclient="no"
	else
		myclient="xaw"
		use sdl && myclient="sdl"
		use Xaw3d && myclient="xaw3d"
		if use gtk ; then
			myclient="gtk-2.0"
		fi
		#FIXME --enable-sdl-mixer actually disable them...
		#FIXME   ==> use --disable-* only, and autodetect to enable.
		use sdl || mysoundconf="${mysoundconf} --disable-sdl-mixer"
	fi

	egamesconf \
		--disable-dependency-tracking \
		$(use_enable auth) \
		$(use_enable nls) \
		$(use_with readline) \
		--without-ggz-client \
		--enable-client=${myclient} \
		${mysoundconf} \
		|| die "egamesconf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if ! use dedicated ; then
		# Install the app-defaults if Xaw/Xaw3d toolkit
		if ! use gtk && ! use sdl ; then
			insinto /etc/X11/app-defaults
			doins data/Freeciv || die "doins failed"
		fi
		# Install sounds if at least one sound plugin was built
		if use sdl ; then
			insinto "${GAMES_DATADIR}"/${PN}
			doins -r ../data/stdsounds* || die "doins sounds failed"
		fi
		# Create and install the html manual. It can't be done for dedicated
		# servers, because the 'civmanual' tool is then not built. Also
		# delete civmanual from the GAMES_BINDIR, because it's then useless.
		# Note: to have it localized, it should be ran from _postinst, or
		# something like that, but then it's a PITA to avoid orphan files...
		./manual/civmanual || die "civmanual failed"
		dohtml manual*.html || die "dohtml failed"
		rm -f "${ED}/${GAMES_BINDIR}"/civmanual
	fi

	dodoc ChangeLog NEWS doc/{BUGS,CodingStyle,HACKING,HOWTOPLAY,README*,TODO}

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
