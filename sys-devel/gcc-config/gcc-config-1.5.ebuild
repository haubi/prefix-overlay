# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc-config/gcc-config-1.5.ebuild,v 1.1 2009/12/20 19:55:21 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib prefix

# Version of .c wrapper to use
W_VER="1.5.1"

DESCRIPTION="Utility to change the gcc compiler being used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="!app-admin/eselect-compiler
	>=sys-devel/binutils-config-1.9-r04.3"

S=${WORKDIR}

src_unpack() {
	cp "${FILESDIR}"/wrapper-${W_VER}.c "${S}"/wrapper.c || die
	cp "${FILESDIR}"/${PN}-${PV}  "${S}/"${PN}-${PV} || die
	eprefixify "${S}"/wrapper.c "${S}"/${PN}-${PV}
}

src_compile() {
	strip-flags

	emake CC="$(tc-getCC)" wrapper || die "compile wrapper"
}

src_install() {
	newbin ${PN}-${PV} ${PN} || die "install gcc-config"
	sed -i \
		-e "s:@GENTOO_LIBDIR@:$(get_libdir):g" \
		"${ED}"/usr/bin/${PN}

	exeinto /usr/$(get_libdir)/misc
	newexe wrapper gcc-config || die "install wrapper"
}

pkg_postinst() {
	# Scrub eselect-compiler remains
	if [[ -e ${EROOT}/etc/env.d/05compiler ]] ; then
		rm -f "${EROOT}"/etc/env.d/05compiler
	fi

	# Make sure old versions dont exist #79062
	rm -f "${EROOT}"/usr/sbin/gcc-config

	# We not longer use the /usr/include/g++-v3 hacks, as
	# it is not needed ...
	[[ -L ${EROOT}/usr/include/g++ ]] && rm -f "${EROOT}"/usr/include/g++
	[[ -L ${EROOT}/usr/include/g++-v3 ]] && rm -f "${EROOT}"/usr/include/g++-v3

	# Do we have a valid multi ver setup ?
	local x
	for x in $(gcc-config -C -l 2>/dev/null | awk '$NF == "*" { print $2 }') ; do
		gcc-config ${x}
	done
}
