# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Compress-Raw-Zlib/Compress-Raw-Zlib-2.015.ebuild,v 1.4 2008/10/21 17:04:33 corsair Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS

inherit multilib perl-module

DESCRIPTION="Low-Level Interface to zlib compression library"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND="dev-lang/perl
	>=sys-libs/zlib-1.2.2.1"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod )"

SRC_TEST="do"

src_unpack() {
	perl-module_src_unpack

	cat <<-EOF > "${S}/config.in"
		BUILD_ZLIB = False
		INCLUDE = ${EPREFIX}/usr/include
		LIB = ${EPREFIX}/usr/${get_libdir}

		OLD_ZLIB = False
		GZIP_OS_CODE = AUTO_DETECT
	EOF
}
