# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/cairomm/cairomm-1.4.4.ebuild,v 1.9 2008/09/30 01:42:25 dang Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="http://cairographics.org/cairomm"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc examples"

RDEPEND=">=x11-libs/cairo-1.4.0"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	if ! use examples; then
		# don't waste time building the examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || \
			die "sed Makefile.in failed"
	fi
}

src_compile() {
	econf $(use_enable doc docs) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	if use examples; then
		cp -R examples "${ED}"/usr/share/doc/${PF}
	fi
}
