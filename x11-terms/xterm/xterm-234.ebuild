# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/xterm/xterm-234.ebuild,v 1.1 2008/03/12 23:15:38 dberkholz Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="Terminal Emulator for X Windows"
HOMEPAGE="http://dickey.his.com/xterm/"
SRC_URI="ftp://invisible-island.net/${PN}/${P}.tgz"

LICENSE="X11"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="truetype Xaw3d unicode toolbar paste64"

RDEPEND="x11-libs/libX11
	x11-libs/libXrender
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libxkbfile
	x11-libs/libXft
	x11-libs/libXaw
	x11-apps/xmessage
	unicode? ( x11-apps/luit )
	Xaw3d? ( x11-libs/Xaw3d )
	kernel_linux? ( sys-libs/libutempter )"
DEPEND="${RDEPEND}
	x11-proto/xproto"

pkg_setup() {
	DEFAULTS_DIR="${EPREFIX}/usr/share/X11/app-defaults"
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# modifications needed to run on interix
	epatch "${FILESDIR}"/${PN}-232-interix.patch
}

src_compile() {
	filter-flags "-fstack-protector"
	replace-flags "-Os" "-O2" # work around gcc-4.1.1-r[01] bugs
	[[ ${CHOST} == *-darwin* ]] && append-flags -D_DARWIN_C_SOURCE
	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	econf --libdir="${EPREFIX}"/etc \
		--with-x \
		--with-utempter \
		--disable-setuid \
		--disable-full-tgetent \
		--disable-imake \
		--disable-narrowproto \
		--enable-ansi-color \
		--enable-256-color \
		--enable-broken-osc \
		--enable-broken-st \
		--enable-load-vt-fonts \
		--enable-i18n \
		--enable-wide-chars \
		--enable-doublechars \
		--enable-warnings \
		--enable-tcap-query \
		--enable-logging \
		--enable-dabbrev \
		--with-app-defaults=${DEFAULTS_DIR} \
		$(use_enable toolbar) \
		$(use_enable truetype freetype) \
		$(use_enable unicode luit) $(use_enable unicode mini-luit) \
		$(use_with Xaw3d) \
		$(use_enable paste64)

	emake || die "emake failed."
}

# Parallel make causes File exists error and dies. Forcing -j1 for now.
src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	dodoc README{,.i18n} ctlseqs.txt
	dohtml xterm.log.html

	# Fix permissions -- it grabs them from live system, and they can
	# be suid or sgid like they were in pre-unix98 pty or pre-utempter days,
	# respectively (#69510).
	# (info from Thomas Dickey) - Donnie Berkholz <spyderous@gentoo.org>
	fperms 0755 /usr/bin/xterm

	# restore the navy blue
	sed -i "s:blue2$:blue:" "${D}"${DEFAULTS_DIR}/XTerm-color

	# Fix for bug #91453 at Thomas Dickey's suggestion:
	echo "*allowWindowOps: 	false" >> "${D}"/${DEFAULTS_DIR}/XTerm
	echo "*allowWindowOps: 	false" >> "${D}"/${DEFAULTS_DIR}/UXTerm
}

pkg_postinst() {
	if use paste64 ; then
		elog "bracketed paste mode requires the allowWindowOps resource to be true"
		elog "which is false by default for security reasons (see bug #91453)."
		elog "To be able to use it add 'allowWindowOps: true' to your resources"
	fi
}
