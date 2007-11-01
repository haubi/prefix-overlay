# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/haddock/haddock-0.8.ebuild,v 1.10 2007/10/31 12:57:11 dcoutts Exp $

EAPI="prefix"

CABAL_FEATURES="bin"
inherit haskell-cabal eutils versionator autotools

MY_PF=$(replace_version_separator 3 '-' ${PF})

DESCRIPTION="A documentation tool for Haskell."
HOMEPAGE="http://haskell.org/haddock/"
SRC_URI="http://haskell.org/haddock/${MY_PF}-src.tar.gz"
LICENSE="as-is"
SLOT="0"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"

IUSE="doc"

DEPEND=">=dev-lang/ghc-6.4
		>=dev-haskell/cabal-1.1.4
	doc? (  ~app-text/docbook-xml-dtd-4.2
			app-text/docbook-xsl-stylesheets
			>=dev-libs/libxslt-1.1.2 )"
RDEPEND=""

S="${WORKDIR}/${MY_PF}"

src_unpack() {
	unpack ${A}
	cd "${S}"/doc

	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify configure.ac
	eautoreconf
}

src_compile () {
	cabal_src_compile
	if use doc; then
		cd ${S}/doc
		autoconf
		./configure --prefix=${ED}/usr/ \
			|| die 'error configuring documentation.'
		make html || die 'error building documentation.'
	fi
}

src_install () {
	cabal_src_install
	if use doc; then
		dohtml -r ${S}/doc/haddock/*
	fi
	dodoc CHANGES LICENSE README
}
