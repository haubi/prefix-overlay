# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnustep-2.eclass,v 1.1 2007/08/18 13:12:57 grobian Exp $

inherit gnustep-base

# Eclass for GNUstep Apps, Frameworks, and Bundles build
#
# maintainer: GNUstep Herd <gnustep@gentoo.org>

DEPEND=">=gnustep-base/gnustep-make-2.0
	virtual/gnustep-back"
RDEPEND="${DEPEND}
	debug? ( >=sys-devel/gdb-6.0 )"

# The following gnustep-based EXPORT_FUNCTIONS are available:
# * gnustep-base_pkg_setup
# * gnustep-base_src_compile 
# * gnustep-base_src_install 
# * gnustep-base_pkg_postinst
