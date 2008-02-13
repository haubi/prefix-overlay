# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-documentation-base/texlive-documentation-base-2007.ebuild,v 1.8 2008/02/10 14:33:37 aballier Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS=""
TEXLIVE_MODULE_CONTENTS="texlive-common texlive-en collection-documentation-base
"
inherit texlive-module
DESCRIPTION="TeXLive Base documentation"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
