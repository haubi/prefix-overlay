# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/genlop/genlop-0.30.8-r1.ebuild,v 1.4 2007/11/15 17:33:47 drac Exp $

EAPI="prefix"

inherit eutils bash-completion

DESCRIPTION="A nice emerge.log parser"
HOMEPAGE="http://www.gentoo.org/proj/en/perl"
SRC_URI="mirror://gentoo//${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.8.0-r12
	 >=dev-perl/DateManip-5.40
	 dev-perl/libwww-perl"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-version.patch"
	epatch "${FILESDIR}"/${PN}-0.30.7-prefix.patch
	eprefixify genlop
	# ugly, but I'm not a perl guru
	[[ ${CHOST} == *-solaris* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps -ef -o pid,args/' genlop
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps ax -o pid,command/' genlop
}

src_install() {
	dobin genlop || die "failed to install genlop (via dobin)"
	dodoc README Changelog
	doman genlop.1
	dobashcompletion genlop.bash-completion genlop
}
