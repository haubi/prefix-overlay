# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/time/time-1.1.1.ebuild,v 1.2 2007/07/11 18:39:28 dcoutts Exp $

EAPI="prefix"

CABAL_FEATURES="lib profile haddock"
inherit haskell-cabal

GHC_PV=6.6.1

DESCRIPTION="A Haskell time library."
HOMEPAGE="http://haskell.org/ghc/"
SRC_URI="http://www.haskell.org/ghc/dist/${GHC_PV}/ghc-${GHC_PV}-src-extralibs.tar.bz2"
LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

DEPEND=">=dev-lang/ghc-6.6"

S="${WORKDIR}/ghc-${GHC_PV}/libraries/${PN}"

# Sadly Setup.hs in the ghc-6.6.1 extralibs was not tested with Cabal-1.1.6.x
src_unpack() {
	unpack "${A}"
	sed -e "/type Hook/ s/UserHooks/Maybe UserHooks/" \
		-e "/^runTestScript ::/ d" \
		-e "s/maybeExit \\\$ //" \
		-i ${S}/Setup.hs
}
