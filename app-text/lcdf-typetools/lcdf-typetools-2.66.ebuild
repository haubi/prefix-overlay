# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/lcdf-typetools/lcdf-typetools-2.66.ebuild,v 1.8 2007/12/18 19:06:53 jer Exp $

EAPI="prefix"

DESCRIPTION="Font utilities for eg manipulating OTF"
SRC_URI="http://www.lcdf.org/type/${P}.tar.gz"
HOMEPAGE="http://www.lcdf.org/type/#typetools"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
SLOT="0"
LICENSE="GPL-2"
IUSE="kpathsea"

DEPEND="kpathsea? ( virtual/tex-base )"

src_compile() {
	econf $(use_with kpathsea) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc NEWS README ONEWS
}
