# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/antiword/antiword-0.37.ebuild,v 1.8 2006/11/21 17:17:34 seemant Exp $

EAPI="prefix"

inherit eutils

IUSE="kde"
PATCHVER=0.1
DESCRIPTION="free MS Word reader"
HOMEPAGE="http://www.winfield.demon.nl"
SRC_URI="http://www.winfield.demon.nl/linux/${P}.tar.gz
	mirror://gentoo/${P}-gentoo-${PATCHVER}.tar.bz2"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86"

PATCHDIR=${WORKDIR}/gentoo-antiword/patches

src_unpack() {
	unpack ${A} ; cd ${S}
	EPATCH_SUFFIX="diff" \
		epatch ${PATCHDIR}
}

src_compile() {
	emake OPT="${CFLAGS}" || die
}

src_install() {
	# no configure, so use the prefix in the install here
	make DESTDIR="${D}${EPREFIX}" global_install || die

	use kde || rm -f ${ED}/usr/bin/kantiword

	insinto /usr/share/${PN}/examples
	doins Docs/testdoc.doc Docs/antiword.php

	cd Docs
	doman antiword.1
	dodoc COPYING ChangeLog Exmh Emacs FAQ History Netscape \
	QandA ReadMe Mozilla Mutt
}
