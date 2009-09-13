# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/enca/enca-1.9-r1.ebuild,v 1.13 2009/09/11 17:25:26 patrick Exp $

inherit toolchain-funcs
DESCRIPTION="ENCA detects the character coding of a file and converts it if desired"
HOMEPAGE="http://gitorious.org/enca"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"

DEPEND=">=app-text/recode-3.6_p15"
RDEPEND="${DEPEND}"

src_compile() {
	econf \
		--with-librecode="${EPREFIX}"/usr \
		--enable-external \
		$(use_enable doc gtk-doc) \
		|| die "configure failed"
	if tc-is-cross-compiler; then
		( cd "${S}"/tools && $(tc-getBUILD_CC) -o make_hash make_hash.c ) || die "native make_hash failed"
	fi
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
}
