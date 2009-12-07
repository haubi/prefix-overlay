# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-IO-Zlib/perl-IO-Zlib-1.09.ebuild,v 1.6 2009/12/04 14:16:54 tove Exp $

DESCRIPTION="IO:: style interface to Compress::Zlib"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE=""
DEPEND=""

RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/IO-Zlib-${PV} )"
