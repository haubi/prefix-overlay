# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-ftp/filezilla/filezilla-3.3.2.1-r1.ebuild,v 1.1 2010/04/12 15:32:44 voyageur Exp $

EAPI=2

WX_GTK_VER="2.8"

inherit eutils multilib wxwidgets

MY_PV=${PV/_/-}
MY_P="FileZilla_${MY_PV}"

DESCRIPTION="FTP client with lots of useful features and an intuitive interface"
HOMEPAGE="http://filezilla-project.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}_src.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="aqua dbus nls test"

RDEPEND=">=app-admin/eselect-wxwidgets-0.7-r1
	dev-libs/tinyxml[-stl]
	net-dns/libidn
	>=net-libs/gnutls-2.8.3
	>=x11-libs/wxGTK-2.8.9[aqua?]
	dbus? ( sys-apps/dbus )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	>=sys-devel/libtool-1.4
	nls? ( >=sys-devel/gettext-0.11 )
	test? ( dev-util/cppunit )"

S="${WORKDIR}"/${PN}-${MY_PV}

# for Tiger, can use this patch:
# http://code.technoplaza.net/filezilla/filezilla-3.2.7-tiger-power-management-r1.patch

src_configure() {
	econf $(use_with dbus) $(use_enable nls locales) \
		--with-tinyxml=system \
		--disable-autoupdatecheck || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	doicon src/interface/resources/48x48/${PN}.png || die "doicon failed"

	dodoc AUTHORS ChangeLog NEWS

	if use aqua ; then
		dodir /Applications
		cp -a "${S}"/FileZilla.app "${ED}"/Applications/ || die
		pushd "${ED}"/usr/bin > /dev/null || die
		rm filezilla || die
		cat > filezilla <<-EOF
			#!${EPREFIX}/bin/bash
			open "${EPREFIX}"/Applications/FileZilla.app
		EOF
		chmod 755 filezilla
		popd > /dev/null
	fi
}
