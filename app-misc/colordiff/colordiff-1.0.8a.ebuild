# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/colordiff/colordiff-1.0.8a.ebuild,v 1.1 2009/02/02 04:34:07 darkside Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Colorizes output of diff"
HOMEPAGE="http://colordiff.sourceforge.net/"
#SRC_URI="mirror://sourceforge/colordiff/${P}.tar.gz"
# Hasn't been copied to mirrors yet
SRC_URI="http://${PN}.sourceforge.net/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-apps/diffutils"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.0.7-prefix.patch
	eprefixify colordiff.pl
}

src_compile() {
	# This package has a makefile, but we don't want to run it
	true
}

src_install() {
	newbin colordiff.pl colordiff || die
	newbin cdiff.sh cdiff || die
	insinto /etc
	doins colordiffrc colordiffrc-lightbg || die
	dodoc BUGS CHANGES README TODO
	doman colordiff.1
}
