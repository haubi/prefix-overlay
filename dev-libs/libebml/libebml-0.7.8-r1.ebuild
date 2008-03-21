# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libebml/libebml-0.7.8-r1.ebuild,v 1.1 2008/03/13 11:08:05 aballier Exp $

EAPI="prefix"

inherit multilib toolchain-funcs

DESCRIPTION="Extensible binary format library (kinda like XML)"
HOMEPAGE="http://www.matroska.org/"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

S="${S}/make/linux"

src_compile() {
	emake CC="$(tc-getCC)" CXX="$(tc-getCXX)" || die "emake failed"
}

src_install() {
	einstall libdir="${ED}/usr/$(get_libdir)" || die "make install failed"
	dodoc "${WORKDIR}/${P}/ChangeLog"
}
