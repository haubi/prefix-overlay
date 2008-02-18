# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-domainatrix/embassy-domainatrix-0.1.0-r1.ebuild,v 1.6 2007/02/15 20:18:22 je_fro Exp $

EAPI="prefix"

EBOV="4.0.0"

inherit embassy

DESCRIPTION="Protein domain analysis add-on package for EMBOSS"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~x86-linux ~ppc-macos"
