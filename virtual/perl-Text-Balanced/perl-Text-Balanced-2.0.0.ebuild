# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Text-Balanced/perl-Text-Balanced-2.0.0.ebuild,v 1.14 2009/08/25 10:56:55 tove Exp $

DESCRIPTION="Virtual for Text-Balanced"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"

IUSE=""
DEPEND=""
RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/Text-Balanced-${PV} )"
