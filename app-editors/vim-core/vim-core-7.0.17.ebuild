# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/vim-core/vim-core-7.0.17.ebuild,v 1.12 2006/09/28 22:18:29 gustavoz Exp $

EAPI="prefix"

inherit vim

VIM_VERSION="7.0"
VIM_SNAPSHOT="vim-7.0-r1.tar.bz2"
VIM_GENTOO_PATCHES="vim-7.0-gentoo-patches.tar.bz2"
VIM_ORG_PATCHES="vim-patches-7.0.17.tar.gz"
VIMRC_FILE_SUFFIX="-r3"

SRC_URI="${SRC_URI}
	mirror://gentoo/${VIM_SNAPSHOT}
	mirror://gentoo/${VIM_GENTOO_PATCHES}
	mirror://gentoo/${VIM_ORG_PATCHES}"

S=${WORKDIR}/vim${VIM_VERSION/.*}
DESCRIPTION="vim and gvim shared files"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""
DEPEND="${DEPEND}"
PDEPEND="!livecd? ( app-vim/gentoo-syntax )"
