# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zip/zip-3.0.ebuild,v 1.6 2009/10/03 15:29:45 ranger Exp $

inherit toolchain-funcs eutils flag-o-matic

MY_P="${PN}${PV//.}"
DESCRIPTION="Info ZIP (encryption support)"
HOMEPAGE="http://www.info-zip.org/"
SRC_URI="mirror://sourceforge/infozip/${MY_P}.zip"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 crypt unicode"

RDEPEND="bzip2? ( app-arch/bzip2 )"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.0-no-crypt.patch #238398
	epatch "${FILESDIR}"/${PN}-3.0-pic.patch
	epatch "${FILESDIR}"/${PN}-3.0-exec-stack.patch
	epatch "${FILESDIR}"/${PN}-3.0-build.patch
}

src_compile() {
	use bzip2 || append-flags -DNO_BZIP2_SUPPORT
	use crypt || append-flags -DNO_CRYPT
	use unicode || append-flags -DNO_UNICODE_SUPPORT
	emake \
		CC="$(tc-getCC)" \
		LOCAL_ZIP="${CFLAGS} ${CPPFLAGS}" \
		-f unix/Makefile generic \
		|| die
}

src_install() {
	dobin zip zipnote zipsplit || die
	doman man/zip{,note,split}.1
	if use crypt ; then
		dobin zipcloak || die
		doman man/zipcloak.1
	fi
	dodoc BUGS CHANGES README* TODO WHATSNEW WHERE proginfo/*.txt
}
