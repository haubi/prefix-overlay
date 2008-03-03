# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/gcc-config-1.4.0-r4.ebuild,v 1.9 2008/01/10 08:50:51 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib

# Version of .c wrapper to use
W_VER="1.5.0"

DESCRIPTION="Utility to change the gcc compiler being used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="!app-admin/eselect-compiler
	>=sys-devel/binutils-config-1.9-r04.3"

S=${WORKDIR}

src_unpack() {
	cp "${FILESDIR}"/wrapper-${W_VER}.c "${S}"/wrapper.c || die
	cp "${FILESDIR}"/${PN}-${PV}-r1  "${S}/"${PN}-${PV} || die
	eprefixify "${S}"/wrapper.c "${S}"/${PN}-${PV}
}

src_compile() {
	strip-flags

	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	emake CC="$(tc-getCC)" wrapper || die "compile wrapper"
}

src_install() {
	newbin ${PN}-${PV} ${PN} || die "install gcc-config"
	sed -i \
		-e "s:PORTAGE-VERSION:${PVR}:g" \
		-e "s:GENTOO_LIBDIR:$(get_libdir):g" \
		"${ED}"/usr/bin/${PN}

	exeinto /usr/$(get_libdir)/misc
	newexe wrapper gcc-config || die "install wrapper"
}

pkg_postinst() {
	# Do we have a valid multi ver setup ?
	if gcc-config --get-current-profile &>/dev/null ; then
		# We not longer use the /usr/include/g++-v3 hacks, as
		# it is not needed ...
		[[ -L ${EROOT}/usr/include/g++ ]] && rm -f "${EROOT}"/usr/include/g++
		[[ -L ${EROOT}/usr/include/g++-v3 ]] && rm -f "${EROOT}"/usr/include/g++-v3
		gcc-config $(${EPREFIX}/usr/bin/gcc-config --get-current-profile)
	fi

	# Scrub eselect-compiler remains
	if [[ -e ${EROOT}/etc/env.d/05compiler ]] ; then
		rm -f "${EROOT}"/etc/env.d/05compiler
	fi

	# Make sure old versions dont exist #79062
	rm -f "${EROOT}"/usr/sbin/gcc-config
}
