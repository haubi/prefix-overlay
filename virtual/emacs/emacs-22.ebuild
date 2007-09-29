# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/emacs/emacs-22.ebuild,v 1.16 2007/09/26 12:55:40 angelos Exp $

EAPI="prefix"

DESCRIPTION="Virtual for GNU Emacs"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND="|| (
			=app-editors/emacs-22*
			>=app-editors/emacs-cvs-22
		)"
