# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libIDL/libIDL-0.8.10.ebuild,v 1.3 2008/03/12 01:49:34 ranger Exp $

EAPI="prefix"

inherit eutils gnome2

DESCRIPTION="CORBA tree builder"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.4"
DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	dev-util/pkgconfig"

DOCS="AUTHORS BUGS ChangeLog HACKING MAINTAINERS NEWS README"

src_unpack() {
	gnome2_src_unpack
	epunt_cxx
}
