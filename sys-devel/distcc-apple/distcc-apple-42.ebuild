# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="a program to distribute compilation of C code across several machines on a network"
HOMEPAGE="http://distcc.samba.org/"
SRC_URI="http://darwinsource.opendarwin.org/tarballs/other/distcc-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}/distcc-${PV}/distcc_dist

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-compilers.patch
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin7.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify Makefile.in src/versinfo.c
}

src_install() {
	emake DESTDIR=${D%/} install || die

	echo "${CHOST}-gcc" >> ../compilers
	echo "${CHOST}-g++" >> ../compilers
	echo "${CHOST}-c++" >> ../compilers
	insinto /etc
	doins ../compilers
}
