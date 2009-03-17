# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-phonon/qt-phonon-4.5.0.ebuild,v 1.2 2009/03/16 08:28:03 aballier Exp $

EAPI="prefix 2"
inherit qt4-build

DESCRIPTION="The Phonon module for the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+dbus"

DEPEND="~x11-libs/qt-gui-${PV}[debug=,glib,qt3support]
	!kde-base/phonon-kde
	!kde-base/phonon-xine
	aqua? ( ~x11-libs/qt-opengl-${PV} )
	!media-sound/phonon
	media-libs/gstreamer
	media-libs/gst-plugins-base
	dbus? ( =x11-libs/qt-dbus-${PV}[debug=] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/phonon
src/plugins/phonon"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/
src"

QCONFIG_ADD="phonon"
QCONFIG_DEFINE="QT_GSTREAMER"

src_configure() {
	myconf="${myconf} -phonon -no-opengl -no-svg
		$(qt_use dbus qdbus)"

	qt4-build_src_configure
}
