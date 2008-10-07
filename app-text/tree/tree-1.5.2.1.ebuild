# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/tree/tree-1.5.2.1.ebuild,v 1.1 2008/09/16 19:51:15 mr_bones_ Exp $

EAPI="prefix"

inherit toolchain-funcs bash-completion eutils

DESCRIPTION="Lists directories recursively, and produces an indented listing of files."
HOMEPAGE="http://mama.indstate.edu/users/ice/tree/"
SRC_URI="ftp://mama.indstate.edu/linux/tree/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_compile() {
	local MYXOBJS=""
	[[ ${CHOST} == *-darwin* ]] && MYXOBJS="strverscmp.o"
	
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS} -DLINUX -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64" \
		LDFLAGS="${LDFLAGS}" \
		XOBJS="${MYXOBJS}" \
		|| die "emake failed"
}

src_install() {
	dobin tree || die "dobin failed"
	doman man/tree.1
	dodoc CHANGES README*
	dobashcompletion "${FILESDIR}"/${PN}.bashcomp
}
