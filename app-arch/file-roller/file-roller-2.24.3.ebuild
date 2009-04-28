# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/file-roller/file-roller-2.24.3.ebuild,v 1.8 2009/04/27 13:09:11 jer Exp $

GCONF_DEBUG="no"

inherit eutils gnome2

DESCRIPTION="archive manager for GNOME"
HOMEPAGE="http://fileroller.sourceforge.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="nautilus"

RDEPEND=">=dev-libs/glib-2.16.0
	>=x11-libs/gtk+-2.13
	>=gnome-base/libgnome-2.6
	>=gnome-base/libgnomeui-2.6
	>=gnome-base/libglade-2.4
	>=gnome-base/gconf-2.6
	nautilus? ( >=gnome-base/nautilus-2.22.2 )"
DEPEND="${RDEPEND}
	gnome-base/gnome-common
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.19
	>=app-text/gnome-doc-utils-0.3.2"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF} --disable-scrollkeeper --disable-static"

	if ! use nautilus ; then
		G2CONF="${G2CONF} --disable-nautilus-actions"
	fi
}

src_unpack() {
	gnome2_src_unpack

	# Use absolute path to GNU tar since star doesn't have the same
	# options.  On Gentoo, star is /usr/bin/tar, GNU tar is /bin/tar
	epatch "${FILESDIR}"/${PN}-2.10.3-use_bin_tar.patch

	# use a local rpm2cpio script to avoid the dep
	sed -e "s/rpm2cpio/rpm2cpio-file-roller/g" \
		-i src/fr-command-rpm.c || die "sed failed"
}

src_install() {
	gnome2_src_install
	dobin "${FILESDIR}/rpm2cpio-file-roller"
}

pkg_postinst() {
	elog "${PN} is a frontend for several archiving utilities. If you want a"
	elog "particular achive format support, see ${HOMEPAGE}"
	elog "and install the relevant package."
	elog
	elog "for example:"
	elog "  7-zip   - app-arch/p7zip"
	elog "  ace     - app-arch/unace"
	elog "  arj     - app-arch/arj"
	elog "  lzma    - app-arch/lzma"
	elog "  lzop    - app-arch/lzop"
	elog "  cpio    - app-arch/cpio"
	elog "  iso     - app-arch/cdrtools"
	elog "  jar,zip - app-arch/zip and app-arch/unzip"
	elog "  lha     - app-arch/lha"
	elog "  rar     - app-arch/unrar"
	elog "  rpm     - app-arch/rpm"
	elog "  unstuff - app-arch/stuffit"
	elog "  zoo     - app-arch/zoo"
}
