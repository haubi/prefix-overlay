# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/gcc-config-1.3.13-r3.ebuild,v 1.1 2006/07/03 18:57:51 vapier Exp $

EAPI="prefix"

inherit eutils toolchain-funcs multilib

# Version of .c wrapper to use
W_VER="1.4.7"

DESCRIPTION="Utility to change the gcc compiler being used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND=""

S=${WORKDIR}

src_unpack() {
	cp "${FILESDIR}"/wrapper-${W_VER}.c  "${S}/"
	cd "${S}"
	epatch "${FILESDIR}"/wrapper-${W_VER}-prefix.patch
	ebegin "Adjusting source to prefix"
	sed -i \
		-e "s:GENTOO_PORTAGE_EPREFIX:${EPREFIX}:g" \
		wrapper-${W_VER}.c
	eend $?
}

src_compile() {
	$(tc-getCC) -O2 -Wall -o wrapper \
		wrapper-${W_VER}.c || die "compile wrapper"
}

src_install() {
	newbin "${FILESDIR}"/${PN}-${PV} ${PN} || die "install gcc-config"
	patch "${D}"/usr/bin/${PN} < "${FILESDIR}"/${P}-prefix.patch || die
	sed -i \
		-e "s:PORTAGE-VERSION:${PVR}:g" \
		-e "s:GENTOO_LIBDIR:$(get_libdir):g" \
		-e "s:GENTOO_PORTAGE_EPREFIX:${EPREFIX}:g" \
		"${D}"/usr/bin/${PN}

	exeinto /usr/$(get_libdir)/misc
	newexe wrapper gcc-config || die "install wrapper"
}

pkg_postinst() {
	# Do we have a valid multi ver setup ?
	if gcc-config --get-current-profile &>/dev/null ; then
		# We not longer use the /usr/include/g++-v3 hacks, as
		# it is not needed ...
		[[ -L ${ROOT}/usr/include/g++ ]] && rm -f "${ROOT}"/usr/include/g++
		[[ -L ${ROOT}/usr/include/g++-v3 ]] && rm -f "${ROOT}"/usr/include/g++-v3
		[[ ${ROOT} = "/" ]] && gcc-config $(/usr/bin/gcc-config --get-current-profile)
	fi

	# Make sure old versions dont exist #79062
	rm -f "${ROOT}"/usr/sbin/gcc-config
}
