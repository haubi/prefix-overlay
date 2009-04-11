# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/scrollkeeper/scrollkeeper-0.3.14-r2.ebuild,v 1.16 2008/07/05 05:14:46 ricmm Exp $

inherit libtool eutils

DESCRIPTION="cataloging system for documentation on open systems"
HOMEPAGE="http://scrollkeeper.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="FDL-1.1 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

RDEPEND=">=dev-libs/libxml2-2.4.19
	>=dev-libs/libxslt-1.0.14
	>=sys-libs/zlib-1.1.3
	~app-text/docbook-xml-dtd-4.1.2
	app-text/docbook-xsl-stylesheets"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.29
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-gcc2_fix.patch
	epatch "${FILESDIR}"/${P}-nls.patch

	elibtoolize
}

src_compile() {
	econf \
		--localstatedir="${EPREFIX}"/var \
		--with-omfdirs="${EPREFIX}"/usr/share/omf:"${EPREFIX}"/usr/local/share/omf:"${EPREFIX}"/opt/gnome/share/omf:"${EPREFIX}"/opt/gnome-2.0/share/omf:"${EPREFIX}"/opt/kde/omf \
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog \
		$(use_enable nls) \
		|| die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/scrollkeeper-logrotate scrollkeeper

	dodoc AUTHORS ChangeLog NEWS README TODO scrollkeeper-spec.txt
}

pkg_preinst() {
	if [[ -d ${EROOT}/usr/share/scrollkeeper/Templates ]] ; then
		rm -rf "${EROOT}"/usr/share/scrollkeeper/Templates
	fi
}

pkg_postinst() {
	einfo "Installing catalog..."
	"${EROOT}"/usr/bin/xmlcatalog --noout --add "public" \
		"-//OMF//DTD Scrollkeeper OMF Variant V1.0//EN" \
		"`echo "${EROOT}/usr/share/xml/scrollkeeper/dtds/scrollkeeper-omf.dtd" | sed -e "s://:/:g"`" \
		"${EROOT}"/etc/xml/catalog
	einfo "Rebuilding Scrollkeeper database..."
	scrollkeeper-rebuilddb -q -p "${EROOT}"/var/lib/scrollkeeper
	einfo "Updating Scrollkeeper database..."
	scrollkeeper-update -v &> "${T}"/foo
}

pkg_postrm() {
	if [[ ! -x ${EROOT}/usr/bin/scrollkeeper-config ]] ; then
		# SK is being removed, not upgraded.
		# Remove all generated files
		einfo "Cleaning up ${EROOT}/var/lib/scrollkeeper..."
		rm -rf "${EROOT}"/var/lib/scrollkeeper
		rm -rf "${EROOT}"/var/log/scrollkeeper.log
		rm -rf "${EROOT}"/var/log/scrollkeeper.log.1
		"${EROOT}"/usr/bin/xmlcatalog --noout --del \
			"${EROOT}/usr/share/xml/scrollkeeper/dtds/scrollkeeper-omf.dtd" \
			"${EROOT}"/etc/xml/catalog

		elog "Scrollkeeper ${PV} unmerged, if you removed the package"
		elog "you might want to clean up ${EPREFIX}/var/lib/scrollkeeper."
	fi
}
