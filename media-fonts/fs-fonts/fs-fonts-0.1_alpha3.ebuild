# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/fs-fonts/fs-fonts-0.1_alpha3.ebuild,v 1.8 2007/04/27 04:05:33 josejx Exp $

EAPI="prefix"

inherit font

IUSE=""
MY_P="${P/_alpha/test}"

DESCRIPTION="Japanese TrueType fonts designed for screen and print"
HOMEPAGE="http://x-tt.sourceforge.jp/fs_fonts/"
SRC_URI="mirror://sourceforge.jp/x-tt/7862/${MY_P}.tar.gz"

KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
LICENSE="public-domain"
SLOT=0

S="${WORKDIR}"
FONT_S="${S}"
FONT_SUFFIX="ttf"
DOCS="AUTHORS *.txt THANKS Changes docs/README"

# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
	font_src_install

	cd docs
	for d in kappa20 k14goth mplus_bitmap_fonts shinonome* Oradano kochi-substitute; do
		docinto $d
		dodoc $d/*
	done
}
