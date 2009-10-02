# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-python/eselect-python-20090824.ebuild,v 1.9 2009/09/20 13:08:22 volkmar Exp $

EAPI="2"

inherit eutils flag-o-matic prefix

DESCRIPTION="Eselect module for management of multiple Python versions"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="gnulib"

RDEPEND=">=app-admin/eselect-1.0.2"
DEPEND="${RDEPEND}
	gnulib? ( dev-libs/gnulib )
	sys-devel/autoconf"

pkg_setup() {
	append-flags -fno-PIC -fno-PIE
	if use gnulib; then
		# solaris2.9 does not have scandir yet
		append-flags -I"${EPREFIX}/usr/$(get_libdir)/gnulib/include"
		append-ldflags -L"${EPREFIX}/usr/$(get_libdir)/gnulib/$(get_libdir)"
		append-libs -lgnu
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-20090814-mac.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	epatch "${FILESDIR}"/${P}-nognu.patch
	epatch "${FILESDIR}"/${P}-link-libs.patch
	eprefixify python.eselect python-wrapper.c
	epatch "${FILESDIR}/${P}-old-glibc.patch"
	./autogen.sh || die "autogen.sh failed"
}

src_install() {
	keepdir /etc/env.d/python
	emake DESTDIR="${D}" install || die "emake install failed"
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-20090804" || ! has_version "${CATEGORY}/${PN}"; then
		run_eselect_python_update="1"
	fi
}

pkg_postinst() {
	if [[ "${run_eselect_python_update}" == "1" ]]; then
		ebegin "Running \`eselect python update\`"
		eselect python update --ignore 3.0 --ignore 3.1 --ignore 3.2 > /dev/null
		eend "$?"
	fi
}
