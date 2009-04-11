# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/texi2html/texi2html-1.76.ebuild,v 1.15 2009/03/18 19:09:21 armin76 Exp $

DESCRIPTION="Perl script that converts Texinfo to HTML"
HOMEPAGE="http://www.nongnu.org/texi2html/"
SRC_URI="http://download.savannah.gnu.org/releases/texi2html/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.6.1"

src_install() {
	#yes, htmldir line is correct, no ${D}
	make DESTDIR="${D}" \
		htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		install || die "Installation Failed"

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
}

pkg_preinst() {
	rm -f "${EROOT}"/usr/bin/texi2html
}
