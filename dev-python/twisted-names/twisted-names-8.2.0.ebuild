# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/twisted-names/twisted-names-8.2.0.ebuild,v 1.1 2009/01/09 17:46:10 patrick Exp $

MY_PACKAGE=Names

inherit twisted versionator

DESCRIPTION="A Twisted DNS implementation"

KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND="=dev-python/twisted-$(get_version_component_range 1-2)*"

IUSE=""
