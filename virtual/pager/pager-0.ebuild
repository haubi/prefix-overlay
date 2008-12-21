# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/pager/pager-0.ebuild,v 1.1 2008/03/21 11:16:02 opfer Exp $

EAPI="prefix"

DESCRIPTION="Virtual for command-line pagers"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| ( sys-apps/less
	sys-apps/more
	sys-apps/most
	app-text/lv )"
