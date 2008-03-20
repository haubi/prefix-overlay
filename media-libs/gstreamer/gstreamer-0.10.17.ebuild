# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gstreamer/gstreamer-0.10.17.ebuild,v 1.3 2008/03/08 19:24:17 tester Exp $

EAPI="prefix"

inherit libtool flag-o-matic eutils

# Create a major/minor combo for our SLOT and executables suffix
PVP=(${PV//[-\._]/ })
PV_MAJ_MIN=${PVP[0]}.${PVP[1]}
#PV_MAJ_MIN=0.10

DESCRIPTION="Streaming media framework"
HOMEPAGE="http://gstreamer.sourceforge.net"
SRC_URI="http://${PN}.freedesktop.org/src/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2"
SLOT=${PV_MAJ_MIN}
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="debug nls test"

RDEPEND=">=dev-libs/glib-2.8
	>=dev-libs/libxml2-2.4.9
	>=dev-libs/check-0.9.2
	debug? ( dev-util/valgrind )"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.5 )
	dev-util/pkgconfig
	!<media-libs/gst-plugins-ugly-0.10.6-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch

	# Needed for sane .so versioning on Gentoo/FreeBSD
	elibtoolize
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && {
		append-flags -D_ALL_SOURCE
		export ac_cv_lib_dl_dladdr=no
	}

	econf --with-package-name="Gentoo GStreamer ebuild" \
		--with-package-origin="http://www.gentoo.org" \
		$(use_enable test tests) \
		$(use_enable debug valgrind) \
		$(use_enable debug) \
		$(use_enable nls)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README RELEASE TODO

	# Remove unversioned binaries to allow SLOT installations in future.
	cd "${ED}"/usr/bin
	local gst_bins
	for gst_bins in $(ls *-${PV_MAJ_MIN}) ; do
		rm ${gst_bins/-${PV_MAJ_MIN}/}
		einfo "Removed ${gst_bins/-${PV_MAJ_MIN}/}"
	done

	cd "${S}"
	dodoc AUTHORS ChangeLog NEWS README RELEASE TODO

	echo "PRELINK_PATH_MASK=${EPREFIX}/usr/lib/${PN}-${PV_MAJ_MIN}" > 60${PN}-${PV_MAJ_MIN}
	doenvd 60${PN}-${PV_MAJ_MIN}
}

pkg_postinst() {
	elog "Gstreamer has known problems with prelinking, as a workaround"
	elog "this ebuild adds the gstreamer plugins to the prelink mask"
	elog "path to stop them from being prelinked. It is imperative"
	elog "that you undo & redo prelinking after building this pack for"
	elog "this to take effect. Make sure the gstreamer lib path is indeed"
	elog "added to the PRELINK_PATH_MASK environment variable."
	elog "For more information see http://bugs.gentoo.org/81512"
}
