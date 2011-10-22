# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/texinfo/texinfo-4.13-r1.ebuild,v 1.3 2011/04/23 12:10:31 dirtyepic Exp $

EAPI="2"

inherit flag-o-matic

DESCRIPTION="The GNU info program and utilities"
HOMEPAGE="http://www.gnu.org/software/texinfo/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND="!=app-text/tetex-2*
	>=sys-libs/ncurses-5.2-r2
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-xz.patch #269742
	touch doc/install-info.1 #354589
	epatch "${FILESDIR}"/${P}-texi2dvi-regexp-range.patch #311885
	touch doc/{texi2dvi,texi2pdf,pdftexi2dvi}.1 #354589
	epatch "${FILESDIR}"/${P}-accentenc-test.patch

	epatch "${FILESDIR}"/${PN}-4.11-prefix.patch
	epatch "${FILESDIR}"/${P}-mint.patch
}

src_configure() {
	use static && append-ldflags -static
	econf $(use_enable nls)
}

src_compile() {
	# Make cross-compiler safe (#196041)
	if tc-is-cross-compiler ; then
		emake -C tools/gnulib/lib || die
	fi

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
	newdoc info/README README.info
	newdoc makeinfo/README README.makeinfo
}
