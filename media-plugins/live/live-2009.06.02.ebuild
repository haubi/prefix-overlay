# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/live/live-2009.06.02.ebuild,v 1.1 2009/06/05 10:07:59 aballier Exp $

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="Source-code libraries for standards-based RTP/RTCP/RTSP multimedia streaming, suitable for embedded and/or low-cost streaming applications"
HOMEPAGE="http://www.live555.com/"
SRC_URI="http://www.live555.com/liveMedia/public/${P/-/.}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

S="${WORKDIR}"

# Alexis Ballier <aballier@gentoo.org>
# Be careful, bump this everytime you bump the package and the ABI has changed.
# If you don't know, ask someone.
LIVE_ABI_VERSION=3

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"

	cp -pPR live live-shared
	mv live live-static

	cp "${FILESDIR}/config.gentoo" live-static
	cp "${FILESDIR}/config.gentoo-so" live-shared

	case ${CHOST} in
		*-solaris*)
			sed -i \
				-e '/^COMPILE_OPTS /s/$/ -DSOLARIS/' \
				-e '/^LIBS_FOR_CONSOLE_APPLICATION /s/$/ -lsocket -lnsl/' \
				live-static/config.gentoo \
				live-shared/config.gentoo-so \
				|| die
		;;
		*-darwin*)
			sed -i \
				-e '/^COMPILE_OPTS /s/$/ -DBSD=1 -DHAVE_SOCKADDR_LEN=1/' \
				-e '/^LINK /s/$/ /' \
				-e '/^LIBRARY_LINK /s/$/ /' \
				-e '/^LIBRARY_LINK_OPTS /s/-Bstatic//' \
				live-static/config.gentoo \
				|| die static
			sed -i \
				-e '/^COMPILE_OPTS /s/$/ -DBSD=1 -DHAVE_SOCKADDR_LEN=1/' \
				-e '/^LINK /s/$/ /' \
				-e '/^LIBRARY_LINK /s/=.*$/= $(CXX) -o /' \
				-e '/^LIBRARY_LINK_OPTS /s:-shared.*$:-undefined suppress -flat_namespace -dynamiclib -install_name '"${EPREFIX}/usr/$(get_libdir)/"'$@:' \
				live-shared/config.gentoo-so \
				|| die shared
		;;
	esac
}

src_compile() {
	tc-export CC CXX LD

	cd "${WORKDIR}/live-static"

	einfo "Beginning static library build"
	./genMakefiles gentoo
	emake -j1 LINK_OPTS="-L. $(raw-ldflags)" TESTPROGS_APP="" MEDIA_SERVER_APP="" || die "failed to build static libraries"

	einfo "Beginning programs build"
	cd "${WORKDIR}/live-static/testProgs"
	emake LINK_OPTS="-L. ${LDFLAGS}" || die "failed to build test programs"
	cd "${WORKDIR}/live-static/mediaServer"
	emake LINK_OPTS="-L. ${LDFLAGS}" || die "failed to build the mediaserver"

	cd "${WORKDIR}/live-shared"
	einfo "Beginning shared library build"
	./genMakefiles gentoo-so
	local suffix=$(get_libname ${LIVE_ABI_VERSION})
	emake -j1 LINK_OPTS="-L. ${LDFLAGS}" LIB_SUFFIX="${suffix#.}" TESTPROGS_APP="" MEDIA_SERVER_APP="" || die "failed to build shared libraries"
}

src_install() {
	for library in UsageEnvironment liveMedia BasicUsageEnvironment groupsock; do
		dolib.a live-static/${library}/lib${library}.a
		dolib.so live-shared/${library}/lib${library}$(get_libname ${LIVE_ABI_VERSION})
		dosym lib${library}$(get_libname ${LIVE_ABI_VERSION}) /usr/$(get_libdir)/lib${library}$(get_libname)

		insinto /usr/include/${library}
		doins live-shared/${library}/include/*h
	done

	# Should we really install these?
	find live-static/testProgs -type f -perm +111 -print0 | \
		xargs -0 dobin

	#install included live555MediaServer aplication
	dobin live-static/mediaServer/live555MediaServer

	# install docs
	dodoc live-static/README
}

pkg_postinst() {
	ewarn "If you are upgrading from a version prior to live-2008.02.08"
	ewarn "Please make sure to rebuild applications built against ${PN}"
	ewarn "like vlc or mplayer. ${PN} may have had ABI changes and ${PN}"
	ewarn "support might be broken."
}
