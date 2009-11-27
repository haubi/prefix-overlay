# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim/vim-7.2.303.ebuild,v 1.1 2009/11/24 19:23:56 lack Exp $

EAPI=2
inherit vim

VIM_VERSION="7.2"
VIM_ORG_PATCHES="vim-patches-${PV}.tar.gz"
PREFIX_VER="5"

SRC_URI="ftp://ftp.vim.org/pub/vim/unix/vim-${VIM_VERSION}.tar.bz2
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-lang.tar.gz
	ftp://ftp.vim.org/pub/vim/extra/vim-${VIM_VERSION}-extra.tar.gz
	mirror://gentoo/${VIM_ORG_PATCHES}
	http://dev.gentoo.org/~grobian/distfiles/vim-misc-prefix-${PREFIX_VER}.tar.bz2"

S="${WORKDIR}/vim${VIM_VERSION/.}"
DESCRIPTION="Vim, an improved vi-style text editor"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	# new prefix patch tarball needs to be rolled!
	rm "${S}/vim-misc-prefix/vim-darwin-optimize.patch" # does not apply

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