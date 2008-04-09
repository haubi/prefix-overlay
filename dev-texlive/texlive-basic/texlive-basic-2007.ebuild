# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-basic/texlive-basic-2007.ebuild,v 1.13 2008/04/08 14:59:09 armin76 Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="
dev-texlive/texlive-documentation-base
"
TEXLIVE_MODULE_CONTENTS="ams amsfonts bibtex cm cmex dvips enctex etex fontname hyphen-base lm makeindex metafont mflogo misc plain xu-hyphen collection-basic
"
inherit texlive-module
DESCRIPTION="TeXLive Essential programs and files"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
