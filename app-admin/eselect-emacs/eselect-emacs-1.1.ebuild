# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-emacs/eselect-emacs-1.1.ebuild,v 1.8 2007/08/01 04:04:06 metalgod Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages Emacs and ctags symlinks"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify *.eselect
}

src_install() {
	insinto /usr/share/eselect/modules
	doins *.eselect || die "doins failed"
	doman *.eselect.5 || die "doman failed"
	dodoc ChangeLog || die "dodoc failed"
}
