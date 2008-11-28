# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libIDL/libIDL-0.8.11.ebuild,v 1.7 2008/11/22 16:02:17 jer Exp $

EAPI="prefix"

inherit eutils gnome2 autotools

DESCRIPTION="CORBA tree builder"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4"
DEPEND="sys-devel/flex
	sys-devel/bison
	dev-util/pkgconfig"

DOCS="AUTHORS BUGS ChangeLog HACKING MAINTAINERS NEWS README"

src_unpack() {
	gnome2_src_unpack
	epunt_cxx

	epatch "${FILESDIR}"/${P}-bison-2.4.patch

	eautoreconf # required for winnt.
}

src_compile() {
	[[ ${CHOST} == *-interix3* ]] && export libIDL_cv_long_long_format=ll

	if [[ ${CHOST} == *-winnt* ]]; then
		export ac_cv_func_popen=yes
		export ac_cv_cpp_nostdinc="-nostdinc"
	fi

	gnome2_src_compile
}
