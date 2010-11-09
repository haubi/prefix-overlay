# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/findutils/findutils-4.5.9.ebuild,v 1.1 2010/08/15 05:33:52 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib autotools

DESCRIPTION="GNU utilities for finding files"
HOMEPAGE="http://www.gnu.org/software/findutils/"
SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.gz"
#	mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls selinux static"

RDEPEND="selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Don't build or install locate because it conflicts with slocate,
	# which is a secure version of locate.  See bug 18729
	sed -i '/^SUBDIRS/s/locate//' Makefile.in

	epatch "${FILESDIR}"/${P}-interix-mntlist.patch
	epatch "${FILESDIR}"/${P}-interix-arg_max.patch
	epatch "${FILESDIR}"/${P}-interix-arg_max-50000.patch

	( cd gnulib && epatch "${FILESDIR}"/${P}-without-selinux.patch )

	eautoreconf # for the interix and selinux patches. remove if both are gone.
}

src_compile() {
	use static && append-ldflags -static

	local myconf
	use userland_GNU || myconf=" --program-prefix=g"

	if echo "#include <regex.h>" | $(tc-getCPP) > /dev/null ; then
		myconf="${myconf} --without-included-regex"
	fi
	use selinux || myconf="${myconf} --without-selinux" # no --with-selinux

	econf \
		$(use_enable nls) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/find \
		${myconf} \
		|| die "configure failed"
	emake AR="$(tc-getAR)" || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc NEWS README TODO ChangeLog
}
