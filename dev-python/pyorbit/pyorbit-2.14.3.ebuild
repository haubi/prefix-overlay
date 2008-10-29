# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pyorbit/pyorbit-2.14.3.ebuild,v 1.12 2008/10/27 10:29:01 hawking Exp $

EAPI="prefix"

inherit python gnome2 multilib

DESCRIPTION="ORBit2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-lang/python-2.4
	>=gnome-base/orbit-2.12"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.12.0"

DOCS="AUTHORS ChangeLog INSTALL NEWS README TODO"

src_unpack() {
	unpack ${A}
	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

src_install() {
	python_need_rebuild
	gnome2_src_install

	python_version
	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/CORBA.py \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_CORBA.py

	mv "${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/PortableServer.py \
		"${ED}"/usr/$(get_libdir)/python${PYVER}/site-packages/pyorbit_PortableServer.py
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	python_mod_cleanup
}
