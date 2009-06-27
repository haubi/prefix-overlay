# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.0.7.ebuild,v 1.2 2009/06/24 08:12:26 scarabeus Exp $

inherit multilib eutils

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h

GLEXT="52"
GLXEXT="21"

# one day is too much for me to wait, unmask this tomorow
# @ 23.6.09
#MIRROR="mirror://gentoo/"
MIRROR="http://dev.gentooexperimental.org/~scarabeus/"
SRC_URI="${MIRROR}/glext.h-${GLEXT}.bz2
	${MIRROR}/glxext.h-${GLXEXT}.bz2
	${MIRROR}/opengl.eselect-${PV}.bz2"

LICENSE="GPL-2"
SLOT="0"
# -* to give time for headers to hit mirrors...
#KEYWORDS="-*"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
EMULTILIB_PKG="true"

DEPEND="app-arch/bzip2"
RDEPEND=">=app-admin/eselect-1.1"

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	mv opengl.eselect-${PV} opengl.eselect
	mv glext.h-${GLEXT} glext.h
	mv glxext.h-${GLXEXT} glxext.h

#	epatch "${FILESDIR}"/${PN}-1.0.6-solaris64.patch
	epatch "${FILESDIR}"/${P}-darwin.patch
	epatch "${FILESDIR}"/${P}-soname-copy-for-prefix.patch
	sed -i -e "/^\(ENV_FILE=\|PREFIX=\|DST_PREFIX=\)/s:ROOT}:ROOT}${EPREFIX}:" \
		opengl.eselect || die
}

pkg_preinst() {
	# It needs to be before 04multilib
	[[ -f "${EROOT}/etc/env.d/09opengl" ]] && mv ${EROOT}/etc/env.d/09opengl ${EROOT}/etc/env.d/03opengl

	OABI="${ABI}"
	for ABI in $(get_install_abis); do
		if [[ -e "${EROOT}/usr/$(get_libdir)/opengl/xorg-x11/lib/libMesaGL.so" ]]
		then
			einfo "Removing libMesaGL.so from xorg-x11 profile. See bug #47598."
			rm -f "${EROOT}/usr/$(get_libdir)/opengl/xorg-x11/lib/libMesaGL.so"
		fi
		if [[ -e "${EROOT}/usr/$(get_libdir)/libMesaGL.so" ]]
		then
			einfo "Removing libMesaGL.so from /usr/$(get_libdir).  See bug #47598."
			rm -f "${EROOT}/usr/$(get_libdir)/libMesaGL.so"
		fi

		for f in "${EROOT}/usr/$(get_libdir)"/libGL.so.* "${EROOT}/usr/$(get_libdir)"/libGLcore.so.* "${EROOT}/usr/$(get_libdir)"/libnvidia-tls* "${EROOT}/usr/$(get_libdir)"/tls/libnvidia-tls* ; do
			[[ -e ${f} ]] && rm -f "${f}"
		done
	done
	ABI="${OABI}"
	unset OABI
}

pkg_postinst() {
	local impl="$(eselect opengl show)"
	if [[ -n "${impl}"  && "${impl}" != '(none)' ]] ; then
		eselect opengl set "${impl}"
	fi
}

src_install() {
	insinto /usr/share/eselect/modules
	doins opengl.eselect

	# Install default glext.h
	insinto "/usr/$(get_libdir)/opengl/global/include"
	doins "${WORKDIR}/glext.h" || die
	doins "${WORKDIR}/glxext.h" || die
}
