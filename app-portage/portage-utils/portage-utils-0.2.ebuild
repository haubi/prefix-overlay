# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-utils/portage-utils-0.2.ebuild,v 1.5 2009/04/06 01:58:26 vapier Exp $

inherit toolchain-funcs eutils flag-o-matic prefix

DESCRIPTION="small and fast portage helper tools written in C"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="
	ppc-aix? ( dev-libs/gnulib )
	x86-interix? ( dev-libs/gnulib )
	ia64-hpux? ( dev-libs/gnulib )
"

src_unpack() {
	unpack ${A}
	cd ${S}
	sed -i -e 's:\[\[:[:' -e 's:\]\]:]:' Makefile

	epatch "${FILESDIR}"/${P}-gnulib.patch
	epatch "${FILESDIR}"/${PN}-0.1.29-darwin.patch
	epatch "${FILESDIR}"/${PN}-0.1.29-aix.patch
	epatch "${FILESDIR}"/${PN}-0.1.29-interix.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	epatch "${FILESDIR}"/${P}-hpux.patch
}

src_compile() {
	tc-export CC
	# note: Solaris 10+ fails to compile with gnulib, due to static/nonstatic
	# declaration of strcasecmp, it doesn't need gnulib
	if [[ ${CHOST} == *-aix* || ${CHOST} == *-interix[35]* || ${CHOST} == ia64*-hpux* ]]; then
		append-flags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		# append-libs doesn't work, since the Makefile doesn't know LIBS, it seems
		append-ldflags -lgnu
	fi
	emake EPREFIX="${EPREFIX}" || die
}

src_install() {
	emake install EPREFIX="${EPREFIX}" DESTDIR="${D}" || die
}

pkg_postinst() {
	[ -e "${EROOT}"/etc/portage/bin/post_sync ] && return 0
	mkdir -p "${EROOT}"/etc/portage/bin/

cat <<__EOF__ > "${EROOT}"/etc/portage/bin/post_sync
#!${EPREFIX}/bin/sh
# Copyright 2006-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

if [ -d ${EPREFIX}/etc/portage/postsync.d/ ]; then
	for f in ${EPREFIX}/etc/portage/postsync.d/* ; do
		if [ -x \${f} ] ; then
			\${f}
		fi
	done
else
	:
fi
__EOF__
	chmod 755 "${EROOT}"/etc/portage/bin/post_sync
	if [ ! -e "${EROOT}"/etc/portage/postsync.d/q-reinitialize ]; then
		mkdir -p "${EROOT}"/etc/portage/postsync.d/
		echo '[ -x '"${EPREFIX}"'/usr/bin/q ] && '"${EPREFIX}"'/usr/bin/q -qr' > "${EROOT}"/etc/portage/postsync.d/q-reinitialize
		elog "${EROOT}/etc/portage/postsync.d/q-reinitialize has been installed for convenience"
		elog "If you wish for it to be automatically run at the end of every --sync simply chmod +x ${EROOT}/etc/portage/postsync.d/q-reinitialize"
		elog "Normally this should only take a few seconds to run but file systems such as ext3 can take a lot longer."
	fi
	:
}
