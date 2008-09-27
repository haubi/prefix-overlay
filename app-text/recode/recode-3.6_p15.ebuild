# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/recode/recode-3.6_p15.ebuild,v 1.1 2008/09/25 11:18:05 loki_val Exp $

EAPI="prefix"

WANT_AUTOMAKE="1.4"

inherit autotools eutils libtool toolchain-funcs

MY_P=${P%_*}
MY_PV=${PV%_*}
DEB_PATCH=${PV#*p}

DESCRIPTION="Convert files between various character sets"
HOMEPAGE="http://recode.progiciels-bpi.ca/"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz
	mirror://debian/pool/main/r/${PN}/${PN}_${MY_PV}-${DEB_PATCH}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${PN}_${MY_PV}-${DEB_PATCH}.diff
	sed -i '1i#include <stdlib.h>' src/argmatch.c || die

	# Needed under FreeBSD, too
	# Needed under Interix too
	# now replaced by the -new.patch ...
	# epatch "${FILESDIR}"/${MY_P}-ppc-macos.diff
	epatch "${FILESDIR}"/${MY_P}-ppc-macos-new.diff
	[[ ${CHOST} == *-interix[35]* ]] && epatch "${FILESDIR}"/${P}-interix-getopt.patch
	cp lib/error.c lib/xstrdup.c lib/getopt.c lib/getopt1.c src/ || die "file copy failed"

	# really need the new libtool... (they try quite hard to keep
	# theirs ...)
	rm -f m4/libtool.m4 acinclude.m4
	AT_M4DIR="m4" eautoreconf # need new libtool for interix
}

src_compile() {
	tc-export CC LD
	# --without-included-gettext means we always use system headers
	# and library
	econf --without-included-gettext $(use_enable nls) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BACKLOG ChangeLog NEWS README THANKS TODO
	rm -f "${ED}"/usr/lib/charset.alias
}
