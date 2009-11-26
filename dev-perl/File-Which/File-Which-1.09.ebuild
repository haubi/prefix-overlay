# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/File-Which/File-Which-1.09.ebuild,v 1.2 2009/11/25 12:34:18 tove Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Perl module implementing 'which' internally"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="test"

RDEPEND=""
DEPEND="test? ( >=dev-perl/Test-Script-1.06 )"

SRC_TEST="do"
