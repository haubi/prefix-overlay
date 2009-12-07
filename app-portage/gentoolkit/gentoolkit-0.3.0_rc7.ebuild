# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.3.0_rc7.ebuild,v 1.3 2009/12/05 23:00:35 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils prefix

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~ppc-aix ~x64-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND="sys-apps/portage
	dev-lang/python[xml]
	dev-lang/perl
	sys-apps/grep
	sys-apps/gawk"
RDEPEND="${DEPEND}"
RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.3.0_rc7-revdep-prefix.patch
	epatch "${FILESDIR}"/${PN}-0.3.0_rc7-eclean-prefix.patch
	epatch "${FILESDIR}"/${PN}-0.3.0_rc7-setup-prefix.patch

	ebegin "Adjusting to prefix (sloppyly)"
	find . -mindepth 2 -type f | grep -v Makefile | xargs sed -i \
		-e "s|/usr/lib/gentoolkit/pym|${EPREFIX}/usr/lib/gentoolkit/pym|g" \
		-e "s|/usr/lib/portage/pym|${EPREFIX}/usr/lib/portage/pym|g" \
		-e "s|/usr/share/|${EPREFIX}/usr/share/|g" \
		-e "s|^#!/usr/bin/python|#!${EPREFIX}/usr/bin/python|g" \
		-e "s|^#!/bin/bash|#!${EPREFIX}/bin/bash|g" \
		-e "s|=/etc|=${EPREFIX}/etc|g"
	eend $?
	eprefixify data/revdep-rebuild/99revdep-rebuild bin/revdep-rebuild bin/eclean setup.py
}

src_install() {
	distutils_src_install

	# Create cache directory for revdep-rebuild
	dodir /var/cache/revdep-rebuild
	keepdir /var/cache/revdep-rebuild
	use prefix || fowners root:root /var/cache/revdep-rebuild
	fperms 0700 /var/cache/revdep-rebuild

	# remove on platforms where it's broken anyway
	[[ ${CHOST} != *-aix* ]] && rm "${ED}"/usr/bin/revdep-rebuild

	# Gentoolkit scripts can use this to report a consistant version
	dodir /usr/share/gentoolkit
	insinto /usr/share/gentoolkit
	doins VERSION

	# Can distutils handle this?
	dosym eclean /usr/bin/eclean-dist
	dosym eclean /usr/bin/eclean-pkg
}

pkg_postinst() {
	distutils_pkg_postinst

	# Make sure that our ownership and permissions stuck
	use prefix || chown root:root "${EROOT}/var/cache/revdep-rebuild"
	chmod 0700 "${EROOT}/var/cache/revdep-rebuild"

	einfo
	elog "The default location for revdep-rebuild files has been moved"
	elog "to /var/cache/revdep-rebuild when run as root."
	einfo
	einfo "Another alternative to equery is app-portage/portage-utils"
	einfo
	einfo "For further information on gentoolkit, please read the gentoolkit"
	einfo "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
	einfo
	ewarn "This version of gentoolkit contains a rewritten version of equery"
	ewarn "and the gentoolkit library.  Because of this, the documentation is"
	ewarn "out of date.  Please check http://bugs.gentoo.org/269071 when"
	ewarn "filing bugs to see if your issue is being addressed."
	ewarn
	ewarn "glsa-check since gentoolkit 0.3 has modified some output,"
	ewarn "options and default behavior. The list of injected GLSAs"
	ewarn "has moved to /var/lib/portage/glsa_injected, please"
	ewarn "run 'glsa-check -p affected' before copying the existing checkfile."
}
