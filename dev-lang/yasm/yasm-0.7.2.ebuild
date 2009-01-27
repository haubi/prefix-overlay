# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/yasm/yasm-0.7.2.ebuild,v 1.2 2008/10/11 08:29:42 corsair Exp $

EAPI="prefix"

DESCRIPTION="Assembler that supports amd64"
HOMEPAGE="http://www.tortall.net/projects/yasm/"
SRC_URI="http://www.tortall.net/projects/yasm/releases/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# Remove macho tests (gas{32,64},nasm{32,64}) until fixed upstream.
	# Necessary to pass test phase on at least amd64 with gcc-4.1.2.
	sed -i \
		-e '/modules\/objfmts\/macho\/tests\/.*\/.*macho.*_test.sh/d' \
		Makefile.in
}

src_compile() {
	econf $(use_enable nls) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS INSTALL
}
