# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-File-Spec/perl-File-Spec-3.30.ebuild,v 1.2 2009/08/25 10:56:54 tove Exp $

DESCRIPTION="Virtual for File-Spec"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

IUSE=""
DEPEND=""
RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/File-Spec-${PV} )"
