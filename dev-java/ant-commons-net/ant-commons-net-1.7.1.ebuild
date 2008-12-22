# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-commons-net/ant-commons-net-1.7.1.ebuild,v 1.4 2008/12/21 13:33:44 maekke Exp $

EAPI="prefix 1"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND=">=dev-java/commons-net-1.4.1-r1:0"
RDEPEND="${DEPEND}"
