# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ctags/ctags-5.5.4-r3.ebuild,v 1.8 2007/07/12 01:05:42 mr_bones_ Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Exuberant Ctags creates tags files for code browsing in editors"
HOMEPAGE="http://ctags.sourceforge.net"
SRC_URI="mirror://sourceforge/ctags/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/${P}-ebuilds.patch"
	epatch "${FILESDIR}/${P}-ruby-classes.patch"
	epatch "${FILESDIR}/${P}-haskell.patch"
	epatch "${FILESDIR}/${P}-objc.patch"
	epatch "${FILESDIR}/${P}-vim-c.patch"
}

src_compile() {
	econf \
		--with-posix-regex \
		--without-readlib \
		--disable-etags \
		--enable-tmpdir=/tmp \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"

	# namepace collision with X/Emacs-provided /usr/bin/ctags -- we
	# rename ctags to exuberant-ctags (Mandrake does this also).
	mv ${ED}/usr/bin/{ctags,exuberant-ctags}
	mv ${ED}/usr/share/man/man1/{ctags,exuberant-ctags}.1

	dodoc FAQ NEWS README
	dohtml EXTENDING.html ctags.html
}
