# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler-data/poppler-data-0.2.1.ebuild,v 1.8 2008/12/07 11:46:16 vapier Exp $

DESCRIPTION="Data files for poppler to support uncommon encodings without xpdfrc"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="adobe-ps MIT"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	emake prefix="${EPREFIX}"/usr DESTDIR="${D}" install || die "emake install failed"
	dodoc README
}
