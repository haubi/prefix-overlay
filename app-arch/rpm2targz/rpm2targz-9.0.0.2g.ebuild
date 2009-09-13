# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rpm2targz/rpm2targz-9.0.0.2g.ebuild,v 1.2 2009/09/10 15:56:20 ssuominen Exp $

inherit toolchain-funcs eutils

DESCRIPTION="Convert a .rpm file to a .tar.gz archive"
HOMEPAGE="http://www.slackware.com/config/packages.php"
SRC_URI="mirror://gentoo/${P}.tar.lzma"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="userland_GNU"

# NOTE: rpm2targz autodetects rpm2cpio at runtime, and uses it if available,
#       so we don't explicitly set it as a dependency.
RDEPEND="app-arch/cpio"
DEPEND="${DEPEND}
	|| ( app-arch/xz-utils app-arch/lzma-utils )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i '/^prefix =/s:=.*:= '"${EPREFIX}"'/usr:' Makefile
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc *.README*
}
