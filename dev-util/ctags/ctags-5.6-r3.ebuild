# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ctags/ctags-5.6-r3.ebuild,v 1.4 2007/09/24 20:16:05 hawking Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Exuberant Ctags creates tags files for code browsing in editors"
HOMEPAGE="http://ctags.sourceforge.net"
SRC_URI="mirror://sourceforge/ctags/${P}.tar.gz
	ada? ( mirror://sourceforge/gnuada/ctags-ada-mode-4.3.3.tar.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="ada"

DEPEND=">=app-admin/eselect-emacs-1.1"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch "${FILESDIR}/${P}-ebuilds.patch"
	#epatch "${FILESDIR}/${P}-haskell.patch"
	#epatch "${FILESDIR}/${P}-objc.patch"
	epatch "${FILESDIR}/${P}-php5.patch"

	# enabling Ada support
	if use ada; then
		cp ${WORKDIR}/ctags-ada-mode-4.3.3/ada.c ${S}
		epatch "${FILESDIR}/${PN}-ada.patch"
	fi
}

src_compile() {
	econf \
		--with-posix-regex \
		--without-readlib \
		--disable-etags \
		--enable-tmpdir="${EPREFIX}"/tmp \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "einstall failed"

	# namepace collision with X/Emacs-provided /usr/bin/ctags -- we
	# rename ctags to exuberant-ctags (Mandrake does this also).
	mv "${ED}"/usr/bin/{ctags,exuberant-ctags}
	mv "${ED}"/usr/share/man/man1/{ctags,exuberant-ctags}.1

	dodoc FAQ NEWS README
	dohtml EXTENDING.html ctags.html
}

pkg_postinst() {
	eselect ctags update
	elog "You can set the version to be started by /usr/bin/ctags through"
	elog "the ctags eselect module. \"man ctags.eselect\" for details."
}

pkg_postrm() {
	eselect ctags update
}
