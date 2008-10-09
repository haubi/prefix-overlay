# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/m4-1.4.11.ebuild,v 1.7 2008/04/13 05:07:17 jer Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.lzma"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="examples nls"

# remember: cannot dep on autoconf since it needs us
DEPEND="nls? ( sys-devel/gettext )
	app-arch/lzma-utils"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.4.8-darwin7.patch
	epatch "${FILESDIR}"/${P}-winnt.patch

	# this is ok on winnt, since there has to be a complete
	# host prefix containing all the autotools required.
	[[ ${CHOST} == *-winnt* ]] && eautoreconf
}

src_compile() {
	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && myconf="--program-prefix=g"
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
	use prefix && dosym /usr/bin/m4 /usr/bin/gm4
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
	if use examples ; then
		docinto examples
		dodoc examples/*
		rm -f "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi
	rm -f "${ED}"/usr/lib/charset.alias #172864
}
