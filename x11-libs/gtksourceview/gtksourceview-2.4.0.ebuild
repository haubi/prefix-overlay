# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gtksourceview/gtksourceview-2.4.0.ebuild,v 1.1 2008/10/07 10:59:55 leio Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="A text widget implementing syntax highlighting and other features"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="2.0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.12
	>=dev-libs/libxml2-2.5
	>=dev-libs/glib-2.14"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING MAINTAINERS NEWS README"

src_install() {
	gnome2_src_install

	insinto /usr/share/${PN}-2.0/language-specs
	doins "${FILESDIR}"/2.0/gentoo.lang
}
