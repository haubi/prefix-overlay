# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libid3tag/libid3tag-0.15.1b-r1.ebuild,v 1.1 2008/05/05 02:53:45 tester Exp $

EAPI="prefix"

inherit eutils multilib autotools

DESCRIPTION="The MAD id3tag library"
HOMEPAGE="http://www.underbit.com/products/mad/"
SRC_URI="mirror://sourceforge/mad/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="debug"

DEPEND="dev-util/gperf"

RDEPEND="${DEPEND}
	>=sys-libs/zlib-1.1.3"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
	epunt_cxx #74489

	epatch "${FILESDIR}/${PV}/*.patch"
}

src_compile() {
	econf $(use_enable debug debugging) || die "configure failed"
	emake || die "make failed"
}

src_install() {
	make install DESTDIR="${D}" || die "make install failed"

	dodoc CHANGES CREDITS README TODO VERSION

	# This file must be updated with every version update
	insinto /usr/$(get_libdir)/pkgconfig
	doins "${FILESDIR}/id3tag.pc"
	sed -i -e "s:libdir=\${exec_prefix}/lib:libdir=${EPREFIX}/usr/$(get_libdir):" \
		"${ED}/usr/$(get_libdir)/pkgconfig/id3tag.pc"
	sed -i -e s:15.0b:15.1b: "${ED}/usr/$(get_libdir)/pkgconfig/id3tag.pc"
}
