# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ezc.eclass,v 1.4 2007/09/01 15:58:17 jokey Exp $

# @ECLASS: php-ezc.eclass
# @MAINTAINER:
# Gentoo PHP team <php-bugs@gentoo.org>
# @BLURB: Provides an easy installation of the eZcomponents.
# @DESCRIPTION:
# This eclass provides means for an easy installation of the eZ components.
# For more information on eZcomponents see http://ez.no/products/ez_components

inherit php-pear-r1

EZC_PKG_NAME="${PN/ezc-/}"

fix_EZC_PV() {
	tmp="${PV}"
	tmp="${tmp/_/}"
	tmp="${tmp/rc/RC}"
	tmp="${tmp/beta/b}"
	EZC_PV="${tmp}"
}

# @ECLASS-VARIABLE: EZC_PV
# @DESCRIPTION:
# Set in ebuild if the eclass ${PV} mangling of beta/rc versions breaks SRC_URI.
[[ -z "${EZC_PV}" ]] && fix_EZC_PV

EZC_PN="${EZC_PKG_NAME}-${EZC_PV}"

S="${WORKDIR}/${EZC_PN}"

DEPEND=">=dev-lang/php-5.1.2
		>=dev-php/PEAR-PEAR-1.4.6"

RDEPEND="${DEPEND}
		dev-php5/ezc-Base"

SRC_URI="http://components.ez.no/get/${EZC_PN}.tgz"
HOMEPAGE="http://ez.no/products/ez_components"
LICENSE="BSD"
