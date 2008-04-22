# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/ant-javamail/ant-javamail-1.7.0-r1.ebuild,v 1.1 2008/04/22 00:02:37 betelgeuse Exp $

EAPI="prefix"

ANT_TASK_DEPNAME="--virtual javamail"

inherit ant-tasks

DESCRIPTION="Apache Ant's optional tasks for javamail"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

DEPEND="java-virtuals/javamail"
RDEPEND="${DEPEND}"

src_unpack() {
	ant-tasks_src_unpack all
}
