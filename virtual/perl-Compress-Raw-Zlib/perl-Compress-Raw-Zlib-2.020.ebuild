# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Compress-Raw-Zlib/perl-Compress-Raw-Zlib-2.020.ebuild,v 1.7 2009/08/25 10:56:44 tove Exp $

DESCRIPTION="Low-Level Interface to zlib compression library"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE=""
DEPEND=""

RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/Compress-Raw-Zlib-${PV} )"
