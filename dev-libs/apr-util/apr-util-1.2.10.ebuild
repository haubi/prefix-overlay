# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr-util/apr-util-1.2.10.ebuild,v 1.10 2007/12/11 10:06:00 vapier Exp $

EAPI="prefix"

inherit autotools eutils flag-o-matic libtool db-use

DBD_MYSQL=84
APR_PV=1.2.11

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRC_URI="mirror://apache/apr/${P}.tar.gz
	mirror://apache/apr/apr-${APR_PV}.tar.gz
	mysql? ( mirror://gentoo/apr_dbd_mysql-r${DBD_MYSQL}.c )"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE="berkdb doc gdbm ldap mysql postgres sqlite sqlite3"
RESTRICT="test"

DEPEND="dev-libs/expat
	>=dev-libs/apr-${PV}
	berkdb? ( =sys-libs/db-4* )
	doc? ( app-doc/doxygen )
	gdbm? ( sys-libs/gdbm )
	ldap? ( =net-nds/openldap-2* )
	mysql? ( =virtual/mysql-5* )
	postgres? ( dev-db/libpq )
	sqlite? ( =dev-db/sqlite-2* )
	sqlite3? ( =dev-db/sqlite-3* )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use mysql ; then
		cp "${DISTDIR}"/apr_dbd_mysql-r${DBD_MYSQL}.c \
			"${S}"/dbd/apr_dbd_mysql.c || die "could not copy mysql driver"
	fi

	./buildconf --with-apr=../apr-${APR_PV} || die "buildconf failed"
	elibtoolize || die "elibtoolize failed"
}

src_compile() {
	local myconf=""

	use ldap && myconf="${myconf} --with-ldap"

	if use berkdb; then
		dbver="$(db_findver sys-libs/db)" || die "Unable to find db version"
		dbver="$(db_ver_to_slot "$dbver")"
		dbver="${dbver/\./}"
		myconf="${myconf} --with-dbm=db${dbver}
		--with-berkeley-db=$(db_includedir):${EPREFIX}/usr/$(get_libdir)"
	else
		myconf="${myconf} --without-berkeley-db"
	fi

	econf --datadir="${EPREFIX}"/usr/share/apr-util-1 \
		--with-apr="${EPREFIX}"/usr \
		--with-expat="${EPREFIX}"/usr \
		$(use_with gdbm) \
		$(use_with mysql) \
		$(use_with postgres pgsql) \
		$(use_with sqlite sqlite2) \
		$(use_with sqlite3) \
		${myconf} || die "econf failed!"

	emake || die "emake failed!"

	if use doc; then
		emake dox || die "make dox failed"
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc CHANGES NOTICE

	if use doc; then
		dohtml docs/dox/html/* || die
	fi

	# This file is only used on AIX systems, which gentoo is not,
	# and causes collisions between the SLOTs, so kill it
	rm "${ED}"/usr/$(get_libdir)/aprutil.exp
}
