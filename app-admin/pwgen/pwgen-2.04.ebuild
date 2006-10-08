# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/pwgen/pwgen-2.04.ebuild,v 1.12 2005/10/06 18:55:15 hansmi Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Password Generator"
HOMEPAGE="http://sourceforge.net/projects/pwgen/"
SRC_URI="mirror://sourceforge/pwgen/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="livecd"

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e 's:$(prefix)/man/man1:$(mandir)/man1:g' Makefile.in
}

src_compile() {
	econf --sysconfdir="${EPREFIX}"/etc/pwgen || die "econf failed"
	make || die
}

src_install() {
	make DESTDIR="${EDEST}" install || die
	use livecd && exeinto /etc/init.d && newexe ${FILESDIR}/pwgen.rc pwgen
}
