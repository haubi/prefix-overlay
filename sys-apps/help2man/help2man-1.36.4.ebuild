# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/help2man/help2man-1.36.4.ebuild,v 1.13 2007/11/03 19:52:48 grobian Exp $

EAPI="prefix"

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="http://www.gnu.org/software/help2man"
SRC_URI="mirror://gnu/help2man/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls elibc_glibc"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	elibc_glibc? ( nls? ( dev-perl/Locale-gettext
		>=sys-devel/gettext-0.12.1-r1 ) )"

src_unpack() {
	unpack ${A}
	cd ${S}
	[[ ${CHOST} == *-darwin* ]] && sed -i \
		-e 's|-fPIC -shared|-dynamiclib|g' \
		Makefile.in
}

src_compile() {
	local myconf
	use elibc_glibc && myconf="${myconf} $(use_enable nls)" \
		|| myconf="${myconf} --disable-nls"

	econf ${myconf} || die
	emake || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog NEWS README THANKS
}
