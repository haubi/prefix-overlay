# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langgerman/texlive-langgerman-2007.ebuild,v 1.6 2007/10/26 19:22:33 fmccor Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="german germbib hyphen-german mkind-german r-und-s uhrzeit umlaute collection-langgerman
"
inherit texlive-module
DESCRIPTION="TeXLive German"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
