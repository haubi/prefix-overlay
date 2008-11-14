# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/exo/exo-0.3.4-r1.ebuild,v 1.8 2008/11/14 01:56:09 darkside Exp $

EAPI="prefix"

inherit eutils xfce44 python multilib autotools

XFCE_VERSION=4.4.2
xfce44
xfce44_core_package

DESCRIPTION="Extensions, widgets and framework library with session management support"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc hal libnotify python"

RDEPEND=">=dev-lang/perl-5.6
	dev-perl/URI
	>=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-manager-${XFCE_MASTER_VERSION}
	>=xfce-base/xfce-mcs-plugins-${XFCE_MASTER_VERSION}
	libnotify? ( x11-libs/libnotify )
	hal? ( >=sys-apps/hal-0.5.7.1 )
	python? ( dev-python/pygtk )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( dev-util/gtk-doc )
	dev-util/intltool"

XFCE_CONFIG="${XFCE_CONFIG}	$(use_enable python) \
	$(use_enable libnotify notifications) \
	$(use_enable hal) --enable-mcs-plugin"

DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"

# See bug 166568 for reference
src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e 's:-Werror::g' "${S}"/configure
	epatch "${FILESDIR}"/${P}-eject.patch
	epatch "${FILESDIR}"/${P}-remove-libmd5.patch

	epatch "${FILESDIR}"/${P}-interix.patch

	# eautoreconf would be preferred here but automake fails, bug #246480
	eautoconf
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && {
		# configure detects getmntent, which is false!
		export ac_cv_func_getmntent=no
	}

	xfce44_src_compile
}

# See bug 164780 for reference
src_install() {
	xfce44_src_install
	rm -f "${ED}"/usr/lib*/python*/site-packages/pyexo.py[co]
	rm -f "${ED}"/usr/lib*/python*/site-packages/${PN}-0.3/${PN}/__init__.py[co]
}

pkg_postinst() {
	xfce44_pkg_postinst
	python_version
	python_mod_optimize /usr/$(get_libdir)/python${PYVER}/site-packages
}

pkg_postrm() {
	xfce44_pkg_postrm
	python_mod_cleanup
}
