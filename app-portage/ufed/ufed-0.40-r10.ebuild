# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/ufed/ufed-0.40-r10.ebuild,v 1.8 2008/10/25 22:37:37 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Gentoo Linux USE flags editor"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2
	http://dev.gentoo.org/~truedfx/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="sys-libs/ncurses"
RDEPEND="${DEPEND}
	dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-useorder.patch
	epatch "${FILESDIR}"/${P}-source.patch
	epatch "${FILESDIR}"/${P}-comments.patch
	epatch "${FILESDIR}"/${P}-masked.patch
	epatch "${FILESDIR}"/${P}-packageusemask.patch
	epatch "${FILESDIR}"/${P}-noremove.patch
	epatch "${FILESDIR}"/${P}-termsize.patch
	epatch "${FILESDIR}"/${P}-multiple-inheritance.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify Portage.pm ufed-curses-help.c ufed.pl
}

src_compile() {
	./configure || die "configure failed"
	emake || die "make failed"
}

src_install() {
	newsbin ufed.pl ufed || die
	doman ufed.8
	insinto /usr/lib/ufed
	doins *.pm || die
	exeinto /usr/lib/ufed
	doexe ufed-curses || die
}
