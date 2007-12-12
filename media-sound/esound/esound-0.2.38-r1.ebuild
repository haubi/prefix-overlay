# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/esound/esound-0.2.38-r1.ebuild,v 1.8 2007/12/11 23:34:29 vapier Exp $

EAPI="prefix"

WANT_AUTOMAKE=1.10
inherit libtool gnome.org eutils autotools flag-o-matic

DESCRIPTION="The Enlightened Sound Daemon"
HOMEPAGE="http://www.tux.org/~ricdude/EsounD.html"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="alsa debug doc ipv6 tcpd"

# esound comes with arts support, but it hasn't been tested yet, feel free to
# submit patches/improvements
DEPEND=">=media-libs/audiofile-0.1.5
	alsa? ( >=media-libs/alsa-lib-0.5.10b )
	doc?  ( app-text/docbook-sgml-utils )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6-r2 )"
#	arts? ( kde-base/arts )

RDEPEND="${DEPEND}
	app-admin/eselect-esd"

src_unpack() {

	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-0.2.32-amd64.patch"

	epatch "${FILESDIR}/${PN}-0.2.36-mode_t.patch"
	epatch "${FILESDIR}/${PN}-0.2.38-as-needed.patch"
	epatch "${FILESDIR}/${PN}-0.2.38-doc.patch"

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	# Strict aliasing problem
	append-flags -fno-strict-aliasing

	econf \
		--sysconfdir="${EPREFIX}"/etc/esd \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_enable alsa) \
		$(use_with tcpd libwrap) \
		--disable-dependency-tracking \
		|| die "Configure failed"

	emake || die "Make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install  || die "Installation failed"
	mv "${ED}/usr/bin/"{esd,esound-esd}

	dodoc AUTHORS ChangeLog MAINTAINERS NEWS README TIPS TODO

	newconfd "${FILESDIR}/esound.conf.d" esound

	extradepend=""
	use tcpd && extradepend=" portmap"
	use alsa && extradepend="$extradepend alsasound"
	sed -e "s/@extradepend@/$extradepend/" "${FILESDIR}/esound.init.d.2" >"${T}/esound"
	doinitd "${T}/esound"
}

pkg_postinst() {
	eselect esd update --if-unset \
		|| die "eselect failed, try removing /usr/bin/esd and re-emerging."
}
