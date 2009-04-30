# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libopenraw/libopenraw-0.0.7.ebuild,v 1.1 2009/04/29 09:10:31 nirbheek Exp $

EAPI=2

inherit eutils

DESCRIPTION="Decoding library for RAW image formats"
HOMEPAGE="http://libopenraw.freedesktop.org"
SRC_URI="http://${PN}.freedesktop.org/download/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk"

# Tests use files not distributed with the source
RESTRICT="test"

RDEPEND=">=dev-libs/boost-1.33
	media-libs/jpeg
	>=dev-libs/libxml2-2.5
	gtk? (
		>=dev-libs/glib-2
		>=x11-libs/gtk+-2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"
# Curl is used for test requiring internet access.
#	test? ( net-misc/curl )

src_prepare() {
	epatch "${FILESDIR}/${P}-fix-includes-gcc-4.4.patch"
}

src_configure() {
	econf \
		--with-boost=${EPREFIX}/usr \
		--disable-dependency-tracking \
		$(use_enable gtk gnome)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO || die "dodoc failed."
}
