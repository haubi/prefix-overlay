# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-ctags/eselect-ctags-1.11.ebuild,v 1.1 2009/11/07 13:23:58 ulm Exp $

inherit eutils

MY_P="eselect-emacs-${PV}"
DESCRIPTION="Manages ctags implementations"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.2.3
	!<=app-admin/eselect-emacs-1.3"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "/^\(bindir\|man1dir\)=/s|=|=\"${EPREFIX}\"|" \
		ctags.eselect || die "failed to prefixify"
}

src_compile() { :; }

src_install() {
	insinto /usr/share/eselect/modules
	doins ctags.eselect || die
	doman ctags.eselect.5 || die
}
