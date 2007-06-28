# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-utils/portage-utils-0.1.28.ebuild,v 1.9 2007/06/27 06:08:03 corsair Exp $

EAPI="prefix"

inherit toolchain-funcs eutils

DESCRIPTION="small and fast portage helper tools written in C"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}

	epatch "${FILESDIR}/qmerge-posix-180871.patch"
	epatch "${FILESDIR}"/${P}-solaris.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify main.c
}

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	dobin q || die "dobin failed"
	doman man/*.[0-9]
	for applet in $(<applet-list) ; do
		dosym q /usr/bin/${applet}
	done
}

pkg_postinst() {
	ROOT=${EROOT}
	[ -e ${EROOT}/etc/portage/bin/post_sync ] && return 0
	mkdir -p ${EROOT}/etc/portage/bin/

cat <<__EOF__ > ${EROOT}/etc/portage/bin/post_sync
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
	chmod 755 ${EROOT}/etc/portage/bin/post_sync
	if [ ! -e ${EROOT}/etc/portage/postsync.d/q-reinitialize ]; then
		mkdir -p ${EROOT}/etc/portage/postsync.d/
		echo '[ -x '"${EPREFIX}"'/usr/bin/q ] && '"${EPREFIX}"'/usr/bin/q -qr' > ${EROOT}/etc/portage/postsync.d/q-reinitialize
		elog "${EROOT}/etc/portage/postsync.d/q-reinitialize has been installed for convenience"
		elog "If you wish for it to be automatically run at the end of every --sync simply chmod +x ${EROOT}/etc/portage/postsync.d/q-reinitialize"
		elog "Normally this should only take a few seconds to run but file systems such as ext3 can take a lot longer."
	fi
	:
}
