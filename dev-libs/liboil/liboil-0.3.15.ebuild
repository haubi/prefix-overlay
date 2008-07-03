# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboil/liboil-0.3.15.ebuild,v 1.2 2008/07/02 12:35:09 drac Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="library of simple functions that are optimized for various CPUs"
HOMEPAGE="http://liboil.freedesktop.org/"
SRC_URI="http://liboil.freedesktop.org/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0.3"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="doc"

DEPEND="=dev-libs/glib-2*"

src_compile() {
	strip-flags
	filter-flags -O?
	append-flags -O2
	econf --disable-dependency-tracking \
		$(use_enable doc gtk-doc) || die "econf failed."
	emake -j1 || die "emake failed."
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS BUG-REPORTING HACKING NEWS README
}
