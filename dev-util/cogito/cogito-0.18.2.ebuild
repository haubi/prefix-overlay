# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cogito/cogito-0.18.2.ebuild,v 1.2 2007/02/07 21:46:47 vapier Exp $

EAPI="prefix"

inherit eutils

MY_PV=${PV//_/}

DESCRIPTION="The GIT scripted toolkit"
HOMEPAGE="http://kernel.org/pub/software/scm/cogito/"
SRC_URI="mirror://kernel/software/scm/${PN}/${PN}-${MY_PV}.tar.bz2
	mirror://gentoo/${PN}-doc-${MY_PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=dev-util/git-1.4.3"
RDEPEND="app-text/rcs
	net-misc/curl"

S=${WORKDIR}/${PN}-${MY_PV}
SDOC=${WORKDIR}/${PN}-doc-${MY_PV}

src_unpack() {
	unpack ${A} ; cd "${S}"

	# t9300-seek won't work under the sandbox
	rm t/t9300-seek.sh
}

src_install() {
	emake install DESTDIR="${D}" prefix="${EPREFIX}/usr" || die "install failed"
	dodoc README* VERSION COPYING

	doman "${SDOC}"/man?/*

	dodir /usr/share/doc/${PF}/{,html,contrib}
	cp "${SDOC}"/html/* "${ED}"/usr/share/doc/${PF}/html
	cp "${S}"/contrib/* "${ED}"/usr/share/doc/${PF}/contrib
}

src_test() {
	# 'make test' from the root runs the tutorial-script which executes
	# other commands such as 'gpg' and creates stuff in portage's $HOME.
	cd "${S}"
	make -C t || die
}
