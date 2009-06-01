# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/diffutils/diffutils-2.8.7-r2.ebuild,v 1.5 2009/03/31 01:17:37 solar Exp $

inherit eutils flag-o-matic

DESCRIPTION="Tools to make diffs and compare files"
HOMEPAGE="http://www.gnu.org/software/diffutils/diffutils.html"
SRC_URI="ftp://alpha.gnu.org/gnu/diffutils/${P}.tar.gz
	mirror://gentoo/${P}-i18n.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

RDEPEND=""
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Removes waitpid() call after pclose() on piped diff stream, closing
	# bug #11728, thanks to D Wollmann <converter@dalnet-perl.org>
	epatch "${FILESDIR}"/diffutils-2.8.4-sdiff-no-waitpid.patch

	# Fix utf8 support.  Patch from MDK. #71689
	epatch "${WORKDIR}"/${P}-i18n.patch

	epatch "${FILESDIR}"/${P}-headers.patch

	epatch "${FILESDIR}"/${P}-interix.patch

	# Make sure we don't try generating the manpages ... this requires
	# 'help2man' which is a perl app which is not available in a
	# stage2 / stage3 ... don't DEPEND on it or we get a DEPEND loop :(
	# for more info, see #55479
	touch man/*.1

	# There's no reason for this crap to use the private version
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c

	# Fix userpriv perm problems #76600
	chmod ug+w config/*
}

src_compile() {
	use static && append-ldflags -static

	if [[ ${CHOST} == *-interix* ]]; then
		# on interix wchar support is broken...
		export ac_cv_header_wchar_h=no
		export ac_cv_header_wctype_h=no
	fi

	econf $(use_enable nls) || die "econf"
	emake || die "make"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README
}
