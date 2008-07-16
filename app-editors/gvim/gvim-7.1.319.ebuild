# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/gvim/gvim-7.1.319.ebuild,v 1.6 2008/07/07 12:16:30 armin76 Exp $

EAPI="prefix"

inherit vim autotools flag-o-matic

VIM_VERSION="7.1"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches-r1.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
GVIMRC_FILE_SUFFIX="-r1"
GVIM_DESKTOP_SUFFIX="-r1"
PREFIX_VER="5"

SRC_URI="ftp://ftp.vim.org/pub/vim/unstable/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="GUI version of the Vim text editor"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="gnome gtk motif nextaw carbon"
DEPEND="${DEPEND}
	~app-editors/vim-core-${PV}
	!aqua? (
		x11-libs/libXext
		gtk? (
			>=x11-libs/gtk+-2.6
			virtual/xft
			gnome? ( >=gnome-base/libgnomeui-2.6 )
		)
		!gtk? (
			motif? (
				x11-libs/openmotif
			)
			!motif? (
				nextaw? (
					x11-libs/neXtaw
				)
				!nextaw? ( x11-libs/libXaw )
			)
		)
	)"

src_unpack() {
	vim_src_unpack || die "vim_src_unpack failed"

	epatch "${FILESDIR}"/${PN}-7.1.285-darwin-x11link.patch
	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-7.1-interix-link.patch
		epatch "${FILESDIR}"/${P}-interix-cflags.patch
	fi
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_sigaction=no
		# WARNING: keep this one in even after cleaning out all the
		# _ALL_SOURCE definitions for interix, since this is for cppflags
		# which isn't set by default. vim needs this due to stupid type
		# checks in configure
		append-cppflags -D_ALL_SOURCE
	fi
	vim_src_compile || die "vim_src_compile failed"
}
