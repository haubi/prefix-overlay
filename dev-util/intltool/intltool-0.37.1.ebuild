# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/intltool/intltool-0.37.1.ebuild,v 1.7 2008/08/12 13:26:57 armin76 Exp $

EAPI="prefix"

inherit gnome.org eutils

DESCRIPTION="Tools for extracting translatable strings from various sourcefiles"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.6
	dev-perl/XML-Parser"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.35.5-update.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	dodoc AUTHORS ChangeLog NEWS README TODO doc/I18N-HOWTO
}
