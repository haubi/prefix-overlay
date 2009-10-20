# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/evolution-data-server/evolution-data-server-2.26.3.ebuild,v 1.5 2009/10/16 23:19:40 maekke Exp $

EAPI="2"

inherit db-use eutils flag-o-matic gnome2 autotools versionator

DESCRIPTION="Evolution groupware backend"
HOMEPAGE="http://www.gnome.org/projects/evolution/"

LICENSE="LGPL-2 Sleepycat"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE="doc ipv6 kerberos gnome-keyring krb4 ldap ssl"

RDEPEND=">=dev-libs/glib-2.16.1
	>=x11-libs/gtk+-2.14
	>=gnome-base/orbit-2.9.8
	>=gnome-base/libbonobo-2.20.3
	>=gnome-base/gconf-2
	>=gnome-base/libglade-2
	>=gnome-base/libgnome-2
	>=dev-libs/libxml2-2
	>=net-libs/libsoup-2.4
	>=dev-libs/libgweather-2.25.4
	>=dev-libs/libical-0.43
	gnome-keyring? ( >=gnome-base/gnome-keyring-2.20.1 )
	>=dev-db/sqlite-3.5
	ssl? (
		>=dev-libs/nspr-4.4
		>=dev-libs/nss-3.9 )
	>=gnome-base/libgnomeui-2
	sys-libs/zlib
	=sys-libs/db-4*
	ldap? ( >=net-nds/openldap-2.0 )
	kerberos? ( virtual/krb5 )
	krb4? ( app-crypt/mit-krb5[krb4] )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35.5
	>=gnome-base/gnome-common-2
	>=dev-util/gtk-doc-am-1.9
	doc? ( >=dev-util/gtk-doc-1.9 )"

DOCS="ChangeLog MAINTAINERS NEWS TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_with ldap openldap)
		$(use_with krb4 krb4 /usr)
		$(use_with kerberos krb5 /usr)
		$(use_enable ssl nss)
		$(use_enable ssl smime)
		$(use_enable ipv6)
		$(use_enable gnome-keyring)
		--with-weather
		--with-libdb=/usr/$(get_libdir)"
}

src_prepare() {
	gnome2_src_prepare

	# Adjust to gentoo's /etc/service
	epatch "${FILESDIR}"/${PN}-1.2.0-gentoo_etc_services.patch

	# Fix broken libdb build
	epatch "${FILESDIR}"/${PN}-2.25.90-no-libdb.patch

	# Rewind in camel-disco-diary to fix a crash
	epatch "${FILESDIR}"/${PN}-1.8.0-camel-rewind.patch

	# Fix building evo-exchange with --as-needed, upstream bug #342830
	# and configure failing to detect kerberos5-libs with as-needed
	epatch "${FILESDIR}"/${PN}-2.25.5-as-needed.patch

	# Fix hang while updating search folders, bug #277864, upstream bug #583507
	epatch "${FILESDIR}/${PN}-2.26.3-camel-vee-folder.patch"

	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" \
			-i gtk-doc.make || die "sed 1 failed"
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=$(type -P true)" \
			-i gtk-doc.make || die "sed 2 failed"
	fi

	# gtk-doc-am and gnome-common needed for this
	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

	# Use NSS/NSPR only if 'ssl' is enabled.
	if use ssl ; then
		sed -i -e "s|mozilla-nss|nss|
			s|mozilla-nspr|nspr|" "${S}"/configure || die "sed failed"
		G2CONF="${G2CONF} --enable-nss=yes"
	else
		G2CONF="${G2CONF} --without-nspr-libs --without-nspr-includes \
		--without-nss-libs --without-nss-includes"
	fi

	# /usr/include/db.h is always db-1 on FreeBSD
	# so include the right dir in CPPFLAGS
	append-cppflags "-I$(db_includedir)"
}

src_install() {
	gnome2_src_install

	if use ldap; then
		MY_MAJORV=$(get_version_component_range 1-2)
		insinto /etc/openldap/schema
		doins "${FILESDIR}"/calentry.schema || die "doins failed"
		dosym "${ED}"/usr/share/${PN}-${MY_MAJORV}/evolutionperson.schema /etc/openldap/schema/evolutionperson.schema
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	if use ldap; then
		elog ""
		elog "LDAP schemas needed by evolution are installed in /etc/openldap/schema"
	fi
}
