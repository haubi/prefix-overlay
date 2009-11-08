# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.1.0.ebuild,v 1.1 2009/11/07 21:57:07 scarabeus Exp $

inherit multilib eutils

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h

GLEXT="56"
GLXEXT="25"

#MIRROR="mirror://gentoo/"
MIRROR="http://dev.gentooexperimental.org/~scarabeus/"
SRC_URI="${MIRROR}/glext.h.${GLEXT}.bz2
	${MIRROR}/glxext.h.${GLXEXT}.bz2
	${MIRROR}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-arch/bzip2"
RDEPEND=">=app-admin/eselect-1.2.4"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "/^\(ENV_FILE=\|PREFIX=\|DST_PREFIX=\)/s:ROOT}:ROOT}${EPREFIX}:" \
		eselect-opengl-${PV}/opengl.eselect || die
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

	# info about removal of .la file
	einfo
	elog "eselect-opengl since version 1.0.9 strips the libGL.la file."
	elog "This file was broken by design and thus removed."
	elog "For fixing all sort of configure issues please run:"
	elog "  lafilefixer --justfixit"
	elog "or run revdep-rebuild if you update from any older release."
	elog "(lafilefixer package can be found as dev-util/lafilefixer)"
}

src_install() {
	insinto /usr/share/eselect/modules
	doins opengl.eselect || die
	doman opengl.eselect.5 || die

	# Install global glext.h and glxext.h
	insinto "/usr/$(get_libdir)/opengl/global/include"
	cd "${WORKDIR}"
	newins glext.h.${GLEXT} glext.h || die
	newins glxext.h.${GLXEXT} glxext.h || die
}
