# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/lighttpd/lighttpd-1.4.25-r3.ebuild,v 1.2 2012/05/02 21:49:38 jdhore Exp $

EAPI="2"

inherit eutils autotools depend.php

DESCRIPTION="Lightweight high-performance web server"
HOMEPAGE="http://www.lighttpd.net/"
SRC_URI="http://download.lighttpd.net/lighttpd/releases-1.4.x/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~x86-macos"
IUSE="bzip2 doc fam fastcgi gdbm ipv6 ldap lua minimal memcache mysql pcre php rrdtool ssl test webdav xattr"

RDEPEND="
	>=sys-libs/zlib-1.1
	bzip2?    ( app-arch/bzip2 )
	fam?      ( virtual/fam )
	gdbm?     ( sys-libs/gdbm )
	ldap?     ( >=net-nds/openldap-2.1.26 )
	lua?      ( >=dev-lang/lua-5.1 )
	memcache? ( dev-libs/libmemcache )
	mysql?    ( >=virtual/mysql-4.0 )
	pcre?     ( >=dev-libs/libpcre-3.1 )
	php?      ( virtual/httpd-php )
	rrdtool?  ( net-analyzer/rrdtool )
	ssl?    ( >=dev-libs/openssl-0.9.7 )
	webdav? (
		dev-libs/libxml2
		>=dev-db/sqlite-3
		!x86-interix? ( sys-fs/e2fsprogs )
	)
	xattr? ( kernel_linux? ( sys-apps/attr ) )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc?  ( dev-python/docutils )
	test? (
		virtual/perl-Test-Harness
		dev-libs/fcgi
	)"

# update certain parts of lighttpd.conf based on conditionals
update_config() {
	local config="/etc/lighttpd/lighttpd.conf"

	# enable php/mod_fastcgi settings
	use php && \
		dosed 's|#.*\(include.*fastcgi.*$\)|\1|' ${config}

	# enable stat() caching
	use fam && \
		dosed 's|#\(.*stat-cache.*$\)|\1|' ${config}
}

# remove non-essential stuff (for USE=minimal)
remove_non_essential() {
	local libdir="${ED}/usr/$(get_libdir)/${PN}"

	# text docs
	use doc || rm -fr "${ED}"/usr/share/doc/${PF}/txt

	# non-essential modules
	rm -f \
		${libdir}/mod_{compress,evhost,expire,proxy,scgi,secdownload,simple_vhost,status,setenv,trigger*,usertrack}.*

	# allow users to keep some based on USE flags
	use pcre    || rm -f ${libdir}/mod_{ssi,re{direct,write}}.*
	use webdav  || rm -f ${libdir}/mod_webdav.*
	use mysql   || rm -f ${libdir}/mod_mysql_vhost.*
	use lua     || rm -f ${libdir}/mod_{cml,magnet}.*
	use rrdtool || rm -f ${libdir}/mod_rrdtool.*

	if ! use fastcgi ; then
		rm -f ${libdir}/mod_fastcgi.*
	fi
}

pkg_setup() {
	if ! use pcre ; then
		ewarn "It is highly recommended that you build ${PN}"
		ewarn "with perl regular expressions support via USE=pcre."
		ewarn "Otherwise you lose support for some core options such"
		ewarn "as conditionals and modules such as mod_re{write,direct}"
		ewarn "and mod_ssi."
		ebeep 5
	fi

	use php && require_php_with_use cgi

	enewgroup lighttpd
	enewuser lighttpd -1 -1 /var/www/localhost/htdocs lighttpd
}

src_prepare() {
	epatch "${FILESDIR}"/1.4.25-fix-unknown-AM_SILENT_RULES.patch
	epatch "${FILESDIR}"/1.4.25-fix-CVE-2010-0295.patch
	# dev-python/docutils installs rst2html.py not rst2html
	sed -i -e 's|\(rst2html\)|\1.py|g' doc/Makefile.am || \
		die "sed doc/Makefile.am failed"

	epatch "${FILESDIR}"/${PN}-darwin-bundle.patch

	eautoreconf
}

src_configure() {
	econf --libdir="${EPREFIX}/usr/$(get_libdir)/${PN}" \
		--enable-lfs \
		$(use_enable ipv6) \
		$(use_with bzip2) \
		$(use_with fam) \
		$(use_with gdbm) \
		$(use_with lua) \
		$(use_with ldap) \
		$(use_with memcache) \
		$(use_with mysql) \
		$(use_with pcre) \
		$(use_with ssl openssl) \
		$(use_with webdav webdav-props) \
		$(use_with webdav webdav-locks) \
		$(use_with xattr attr)
}

src_compile() {
	emake || die "emake failed"

	if use doc ; then
		einfo "Building HTML documentation"
		cd doc
		emake html || die "failed to build HTML documentation"
	fi
}

src_test() {
	if [[ ${EUID} -eq 0 ]]; then
		default_src_test
	else
		ewarn "test skipped, please re-run as root if you wish to test ${PN}"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# init script stuff
	newinitd "${FILESDIR}"/lighttpd.initd lighttpd || die
	newconfd "${FILESDIR}"/lighttpd.confd lighttpd || die
	use fam && has_version app-admin/fam && \
		sed -i 's/after famd/need famd/g' "${ED}"/etc/init.d/lighttpd

	# configs
	insinto /etc/lighttpd
	doins "${FILESDIR}"/conf/lighttpd.conf
	doins "${FILESDIR}"/conf/mime-types.conf
	doins "${FILESDIR}"/conf/mod_cgi.conf
	doins "${FILESDIR}"/conf/mod_fastcgi.conf
	# Secure directory for fastcgi sockets
	keepdir /var/run/lighttpd/
	fperms 0750 /var/run/lighttpd/
	fowners lighttpd:lighttpd /var/run/lighttpd/

	# update lighttpd.conf directives based on conditionals
	update_config

	# docs
	dodoc AUTHORS README NEWS doc/*.sh
	newdoc doc/lighttpd.conf lighttpd.conf.distrib

	use doc && dohtml -r doc/*

	docinto txt
	dodoc doc/*.txt

	# logrotate
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/lighttpd.logrotate lighttpd || die

	keepdir /var/l{ib,og}/lighttpd /var/www/localhost/htdocs
	fowners lighttpd:lighttpd /var/l{ib,og}/lighttpd
	fperms 0750 /var/l{ib,og}/lighttpd

	#spawn-fcgi may optionally be installed via www-servers/spawn-fcgi
	rm -f "${ED}"/usr/bin/spawn-fcgi "${ED}"/usr/share/man/man1/spawn-fcgi.*

	use minimal && remove_non_essential
}

pkg_postinst () {
	echo
	if [[ -f ${EROOT}etc/conf.d/spawn-fcgi.conf ]] ; then
		einfo "spawn-fcgi is now provided by www-servers/spawn-fcgi."
		einfo "spawn-fcgi's init script configuration is now located"
		einfo "at /etc/conf.d/spawn-fcgi."
		echo
	fi

	if [[ -f ${EROOT}etc/lighttpd.conf ]] ; then
		ewarn "Gentoo has a customized configuration,"
		ewarn "which is now located in /etc/lighttpd.  Please migrate your"
		ewarn "existing configuration."
		ebeep 5
	fi

	if use fastcgi; then
		ewarn "As of lighttpd-1.4.22, spawn-fcgi is provided by the separate"
		ewarn "www-servers/spawn-fcgi package. Please install it manually, if"
		ewarn "you use spawn-fcgi."
		ewarn "It features a new, more featurefull init script - please migrate"
		ewarn "your configuration!"
	fi
}
