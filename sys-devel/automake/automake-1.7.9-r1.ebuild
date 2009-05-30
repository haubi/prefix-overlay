# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.7.9-r1.ebuild,v 1.19 2009/05/29 23:41:11 vapier Exp $

inherit eutils

DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://sources.redhat.com/automake/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	sys-devel/automake-wrapper
	>=sys-devel/autoconf-2.59-r6
	sys-devel/gnuconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "/^@setfilename/s|automake|automake${SLOT}|" \
		-e "s|automake: (automake)|automake v${SLOT}: (automake${SLOT})|" \
		-e "s|aclocal: (automake)|aclocal v${SLOT}: (automake${SLOT})|" \
		automake.texi || die "sed texi failed"
	epatch "${FILESDIR}"/${P}-infopage-namechange.patch
	epatch "${FILESDIR}"/${P}-test-fixes.patch
	epatch "${FILESDIR}"/${PN}-1.9.6-subst-test.patch #222225
	epatch "${FILESDIR}"/${P}-libtool-2.patch #257544
	epatch "${FILESDIR}"/${PN}-1.10-ccnoco-ldflags.patch #203914
	export WANT_AUTOCONF=2.5
}

src_install() {
	emake DESTDIR="${D}" install || die
	rm -f "${ED}"/usr/bin/{aclocal,automake}

	dodoc NEWS README THANKS TODO AUTHORS ChangeLog
	doinfo automake${SLOT}.info

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	local x=
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}
