# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-20131210.ebuild,v 1.1 2013/12/10 17:45:14 floppym Exp $

# Keep the EAPI low here because everything else depends on it.
# We want to make upgrading simpler.

if [[ ${PV} == "99999999" ]] ; then
	inherit autotools git-r3
	EGIT_REPO_URI="git://git.overlays.gentoo.org/proj/${PN}.git"
else
	inherit eutils autotools
	SRC_URI="mirror://gentoo/${P}.tar.bz2
		http://dev.gentoo.org/~floppym/dist/${P}.tar.bz2"
	#KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="Eselect module for management of multiple Python versions"
HOMEPAGE="http://www.gentoo.org/proj/en/Python/"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=">=app-admin/eselect-1.2.3"
# Avoid autotool deps for released versions for circ dep issues.
#if [[ ${PV} == "99999999" ]] ; then
	DEPEND="sys-devel/autoconf"
#else
#	DEPEND=""
#fi

src_unpack() {
#	if [[ ${PV} == "99999999" ]] ; then
#		git-r3_src_unpack
		unpack ${A}
		cd "${S}"
		epatch "${FILESDIR}"/${P}-prefix.patch
		eautoreconf
#	else
#		unpack ${A}
#	fi
}

src_install() {
	keepdir /etc/env.d/python
	emake DESTDIR="${D}" install || die
}

pkg_postinst() {
	local ret=0
	ebegin "Running 'eselect python update'"
	eselect python update --python2 --if-unset || ret=1
	eselect python update --python3 --if-unset || ret=1
	eend ${ret}
}
