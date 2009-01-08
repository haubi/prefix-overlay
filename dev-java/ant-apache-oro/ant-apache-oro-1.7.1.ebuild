# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-apache-oro/ant-apache-oro-1.7.1.ebuild,v 1.5 2009/01/07 19:17:50 ranger Exp $

EAPI="prefix 1"

ANT_TASK_DEPNAME="jakarta-oro-2.0"

inherit ant-tasks

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND=">=dev-java/jakarta-oro-2.0.8-r2:2.0"
RDEPEND="${DEPEND}"
