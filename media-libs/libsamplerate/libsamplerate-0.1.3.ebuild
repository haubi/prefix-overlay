# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsamplerate/libsamplerate-0.1.3.ebuild,v 1.2 2008/05/13 09:28:20 drac Exp $

EAPI="prefix"

WANT_AUTOMAKE=1.7

inherit eutils autotools

DESCRIPTION="Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio"
HOMEPAGE="http://www.mega-nerd.com/SRC/"
SRC_URI="http://www.mega-nerd.com/SRC/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="sndfile"

RDEPEND="sndfile? ( >=media-libs/libsndfile-1.0.2 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.14"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.1.2-automagic.patch \
		"${FILESDIR}"/${P}-dontbuild-tests-examples.patch \
		"${FILESDIR}"/${P}-pkg_prog_pkg_config.patch

	# Fix for autoconf 2.62
	sed -i -e '/AC_MSG_WARN(\[\[/d' \
		"${S}/acinclude.m4"

	eautoreconf
}

src_compile() {
	econf \
		--disable-fftw \
		$(use_enable sndfile) \
		--disable-dependency-tracking \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
	dohtml doc/*.html doc/*.css doc/*.png
}
