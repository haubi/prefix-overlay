# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim/vim-7.2.108.ebuild,v 1.1 2009/02/19 19:29:45 lack Exp $

inherit vim 

VIM_VERSION="7.2"
VIM_GENTOO_PATCHES="vim-${VIM_VERSION}-gentoo-patches.tar.bz2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar"
PREFIX_VER="5"

SRC_URI="ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="Vim, an improved vi-style text editor"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND="${DEPEND}
	!minimal? ( ~app-editors/vim-core-${PV} )"
RDEPEND="${RDEPEND}
	!<app-editors/nvi-1.81.5-r4
	!minimal? ( ~app-editors/vim-core-${PV} )"

src_unpack() {
	vim_src_unpack || die "vim_src_unpack failed"

	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-7.1-interix-link.patch
		epatch "${FILESDIR}"/${PN}-7.1.319-interix-cflags.patch
	fi
	epatch "${FILESDIR}"/${PN}-7.1.285-darwin-x11link.patch
	epatch "${FILESDIR}"/${PN}-7.2.021-mint.patch
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_sigaction=no
	fi
	vim_src_compile || die "vim_src_compile failed"
}

