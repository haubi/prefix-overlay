# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.9-r1.ebuild,v 1.1 2007/07/07 06:34:10 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	ftp://ftp.seindal.dk/gnu/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="examples nls"

# remember: cannot dep on autoconf since it needs us
DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-signed-division.patch #184200
	epatch "${FILESDIR}"/${PN}-1.4.8-darwin7.patch
}

src_compile() {
	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && [[ ${PREFIX/\//} != "" ]] && \
		myconf="--program-prefix=g"
	econf \
		$(use_enable nls) \
		--enable-changeword \
		${myconf} \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	# autoconf-2.60 for instance, first checks gm4, then m4.  If we don't have
	# gm4, it might find gm4 from outside the prefix on for instance Darwin
	[[ ${USERLAND} != "GNU" ]] && [[ ${PREFIX/\//} != "" ]] || \
		dosym /usr/bin/m4 /usr/bin/gm4
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
	if use examples ; then
		docinto examples
		dodoc examples/*
		rm -f "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
	rm -f "${ED}"/usr/lib/charset.alias #172864
}
