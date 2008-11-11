# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gnome-doc-utils/gnome-doc-utils-0.12.2-r1.ebuild,v 1.10 2008/11/09 11:29:43 vapier Exp $

EAPI="prefix"

inherit autotools eutils python gnome2

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-libs/libxml2-2.6.12
	 >=dev-libs/libxslt-1.1.8
	 >=dev-lang/python-2"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	~app-text/docbook-xml-dtd-4.4"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	# Make xml2po FHS compliant, bug #190798
	epatch "${FILESDIR}/${P}-fhs.patch"

	# Beware of first install, bug #224609
	AT_M4DIR="tools" eautomake

	# Fix LINGUAS
	intltoolize --force || die "intltoolize failed"
}

pkg_setup() {
	G2CONF="--disable-scrollkeeper"

	if ! built_with_use dev-libs/libxml2 python; then
		eerror "Please re-emerge dev-libs/libxml2 with the python use flag set"
		die "dev-libs/libxml2 needs python use flag"
	fi
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/lib/python${PYVER}/site-packages/xml2po
	gnome2_pkg_postinst
}

pkg_postrm() {
	python_mod_cleanup /usr/lib/python*/site-packages/xml2po
	gnome2_pkg_postrm
}
