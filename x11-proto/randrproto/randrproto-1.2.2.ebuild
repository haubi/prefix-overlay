# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/randrproto/randrproto-1.2.2.ebuild,v 1.5 2009/04/05 21:04:32 maekke Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Randr protocol headers"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"

RDEPEND=""
DEPEND="${RDEPEND}"
