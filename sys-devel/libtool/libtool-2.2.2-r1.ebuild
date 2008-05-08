# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-2.2.2-r1.ebuild,v 1.2 2008/04/22 22:53:02 vapier Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="vanilla"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10"
DEPEND="${RDEPEND}
	sys-apps/help2man"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-flag-order.patch
	epatch "${FILESDIR}"/${P}-AC_LIBLTDL_CONVENIENCE.patch
	if ! use vanilla ; then
		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		cd "${S}"
	fi

	eautoreconf
}

src_compile() {
	local myconf
	# usr/bin/libtool is provided by odcctools
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local x
	for x in libtool libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${ED}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf "${EPREFIX}"/usr/share/gnuconfig/${x##*/} "${x}"
	done
}
