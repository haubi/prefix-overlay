# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libperl/libperl-5.10.1.ebuild,v 1.2 2009/09/27 11:00:50 tove Exp $

inherit multilib

DESCRIPTION="Larry Wall's Practical Extraction and Report Language"
SRC_URI=""
HOMEPAGE="http://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

PDEPEND=">=dev-lang/perl-5.10.1"

pkg_postinst() {
	if [[ -h ${EROOT}/usr/$(get_libdir )/libperl$(get_libname) && \
		! -e ${EROOT}/usr/$(get_libdir )/libperl$(get_libname) ]] ; then
		einfo "Remove symbolic link: ${EROOT}usr/$(get_libdir)/libperl$(get_libname)"
		rm "${EROOT}"/usr/$(get_libdir )/libperl$(get_libname)
	fi
}
