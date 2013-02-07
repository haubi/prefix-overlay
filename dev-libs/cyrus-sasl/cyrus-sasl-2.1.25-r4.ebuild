# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/cyrus-sasl/cyrus-sasl-2.1.25-r4.ebuild,v 1.2 2012/12/21 13:27:37 eras Exp $

EAPI=4
inherit eutils flag-o-matic multilib autotools pam java-pkg-opt-2 db-use

SASLAUTHD_CONF_VER="2.1.21"

DESCRIPTION="The Cyrus SASL (Simple Authentication and Security Layer)."
HOMEPAGE="http://cyrusimap.web.cmu.edu/"
SRC_URI="ftp://ftp.cyrusimap.org/cyrus-sasl/${P}.tar.gz"

LICENSE="BSD-with-attribution"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="authdaemond berkdb gdbm kerberos ldapdb openldap mysql pam postgres sample sqlite
srp ssl static-libs urandom"

DEPEND="authdaemond? ( || ( net-mail/courier-imap mail-mta/courier ) )
	berkdb? ( >=sys-libs/db-3.2 )
	gdbm? ( >=sys-libs/gdbm-1.8.0 )
	kerberos? ( virtual/krb5 )
	openldap? ( net-nds/openldap )
	mysql? ( virtual/mysql )
	pam? ( virtual/pam )
	postgres? ( dev-db/postgresql-base )
	sqlite? ( dev-db/sqlite:3 )
	ssl? ( dev-libs/openssl )
	java? ( >=virtual/jdk-1.4 )"
RDEPEND="${DEPEND}"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-sasldb_al.patch
	epatch "${FILESDIR}"/${P}-saslauthd_libtool.patch
	epatch "${FILESDIR}"/${P}-avoid_pic_overwrite.patch
	epatch "${FILESDIR}"/${P}-autotools_fixes.patch
	epatch "${FILESDIR}"/${P}-as_needed.patch
	epatch "${FILESDIR}"/${P}-missing_header.patch
	epatch "${FILESDIR}"/${P}-gssapi.patch
	epatch "${FILESDIR}"/${P}-lib_before_plugin.patch
	epatch "${FILESDIR}"/${P}-fix_heimdal.patch
	epatch "${FILESDIR}"/${P}-auxprop.patch
	epatch "${FILESDIR}"/${PN}-2.1.23-gss_c_nt_hostbased_service.patch
	epatch "${FILESDIR}"/${PN}-2.1.23+db-5.0.patch
	epatch "${FILESDIR}"/${P}-get_fqhostname.patch
	epatch "${FILESDIR}"/${P}-service_keytabs.patch

	# Get rid of the -R switch (runpath_switch for Sun)
	# >=gcc-4.6 errors out with unknown option
	sed -i -e '/LIB_SQLITE.*-R/s/ -R[^"]*//' configure.in

	# Use plugindir for sasldir
	sed -i '/^sasldir =/s:=.*:= $(plugindir):' \
		"${S}"/plugins/Makefile.{am,in} || die "sed failed"

	AT_M4DIR="${S}/cmulocal ${S}/config" eautoreconf
}

src_configure() {
	append-flags -fno-strict-aliasing
	if [[ ${CHOST} == *-solaris* ]] ; then
		# getpassphrase is defined in /usr/include/stdlib.h
		append-cppflags -DHAVE_GETPASSPHRASE
	else
		# this horrendously breaks things on Solaris
		append-cppflags -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED -D_BSD_SOURCE -DLDAP_DEPRECATED
	fi

	# Java support.
	use java && export JAVAC="${JAVAC} ${JAVACFLAGS}"

	local myconf

	# Add authdaemond support (bug #56523).
	if use authdaemond ; then
		myconf="${myconf} --with-authdaemond=${EPREFIX}/var/lib/courier/authdaemon/socket"
	fi

	# Fix for bug #59634.
	if ! use ssl ; then
		myconf="${myconf} --without-des"
	fi

	if use mysql || use postgres || use sqlite ; then
		myconf="${myconf} --enable-sql"
	else
		myconf="${myconf} --disable-sql"
	fi

	# Default to GDBM if both 'gdbm' and 'berkdb' are present.
	if use gdbm ; then
		einfo "Building with GNU DB as database backend for your SASLdb"
		myconf="${myconf} --with-dblib=gdbm"
	elif use berkdb ; then
		einfo "Building with BerkeleyDB as database backend for your SASLdb"
		myconf="${myconf} --with-dblib=berkeley --with-bdb-incdir=$(db_includedir)"
	else
		einfo "Building without SASLdb support"
		myconf="${myconf} --with-dblib=none"
	fi

	# Use /dev/urandom instead of /dev/random (bug #46038).
	if use urandom ; then
		myconf="${myconf} --with-devrandom=/dev/urandom"
	fi

	# Don't even try to build a framework if on OSX
	myconf="${myconf} --disable-macos-framework"

	econf \
		--enable-login \
		--enable-ntlm \
		--enable-auth-sasldb \
		--disable-cmulocal \
		--disable-krb4 \
		--enable-otp \
		--without-sqlite \
		--with-saslauthd="${EPREFIX}"/var/lib/sasl2 \
		--with-pwcheck="${EPREFIX}"/var/lib/sasl2 \
		--with-configdir="${EPREFIX}"/etc/sasl2 \
		--with-plugindir="${EPREFIX}"/usr/$(get_libdir)/sasl2 \
		--with-dbpath="${EPREFIX}"/etc/sasl2/sasldb2 \
		$(use_with ssl openssl) \
		$(use_with pam) \
		$(use_with openldap ldap) \
		$(use_enable ldapdb) \
		$(use_enable sample) \
		$(use_enable kerberos gssapi) \
		$(use_enable java) \
		$(use_with java javahome ${JAVA_HOME}) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		$(use_with sqlite sqlite3 "${EPREFIX}"/usr/$(get_libdir)) \
		$(use_enable srp) \
		$(use_enable static-libs static) \
		${myconf}
}

src_compile() {
	emake

	# Default location for java classes breaks OpenOffice (bug #60769).
	# Thanks to axxo@gentoo.org for the solution.
	cd "${S}"
	if use java ; then
		jar -cvf ${PN}.jar -C java $(find java -name "*.class")
	fi

	# Add testsaslauthd (bug #58768).
	cd "${S}/saslauthd"
	emake testsaslauthd
}

src_install() {
	emake DESTDIR="${D}" install
	keepdir /var/lib/sasl2 /etc/sasl2

	if use sample ; then
		docinto sample
		dodoc sample/*.c
		exeinto /usr/share/doc/${P}/sample
		doexe sample/client sample/server
	fi

	# Default location for java classes breaks OpenOffice (bug #60769).
	if use java ; then
		java-pkg_dojar ${PN}.jar
		java-pkg_regso "${ED}/usr/$(get_libdir)/libjavasasl$(get_libname)"
		# hackish, don't wanna dig through makefile
		rm -Rf "${ED}/usr/$(get_libdir)/java"
		docinto "java"
		dodoc "${S}/java/README" "${FILESDIR}/java.README.gentoo" "${S}"/java/doc/*
		dodir "/usr/share/doc/${PF}/java/Test"
		insinto "/usr/share/doc/${PF}/java/Test"
		doins "${S}"/java/Test/*.java
	fi

	docinto ""
	dodoc AUTHORS ChangeLog NEWS README doc/TODO doc/*.txt
	newdoc pwcheck/README README.pwcheck
	dohtml doc/*.html

	docinto "saslauthd"
	dodoc saslauthd/{AUTHORS,ChangeLog,LDAP_SASLAUTHD,NEWS,README}

	newpamd "${FILESDIR}/saslauthd.pam-include" saslauthd

	newinitd "${FILESDIR}/pwcheck.rc6" pwcheck

	newinitd "${FILESDIR}/saslauthd2.rc6" saslauthd
	newconfd "${FILESDIR}/saslauthd-${SASLAUTHD_CONF_VER}.conf" saslauthd

	newsbin "${S}/saslauthd/testsaslauthd" testsaslauthd

	use static-libs || find "${ED}"/usr/lib*/sasl2 -name 'lib*.la' -delete
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libsasl2.so.2.0.23
}

pkg_postinst () {
	# Generate an empty sasldb2 with correct permissions.
	if ( use berkdb || use gdbm ) && [[ ! -f "${EROOT}/etc/sasl2/sasldb2" ]] ; then
		einfo "Generating an empty sasldb2 with correct permissions ..."
		echo "p" | "${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -p login \
			|| die "Failed to generate sasldb2"
		"${EROOT}/usr/sbin/saslpasswd2" -f "${EROOT}/etc/sasl2/sasldb2" -d login \
			|| die "Failed to delete temp user"
		chown root:mail "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chown ${EROOT}/etc/sasl2/sasldb2"
		chmod 0640 "${EROOT}/etc/sasl2/sasldb2" \
			|| die "Failed to chmod ${EROOT}/etc/sasl2/sasldb2"
	fi

	if use authdaemond ; then
		elog "You need to add a user running a service using Courier's"
		elog "authdaemon to the 'mail' group. For example, do:"
		elog "	gpasswd -a postfix mail"
		elog "to add the 'postfix' user to the 'mail' group."
	fi

	preserve_old_lib_notify /usr/$(get_libdir)/libsasl2.so.2.0.23
}
