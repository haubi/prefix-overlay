# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Module-Build/Module-Build-0.35.ebuild,v 1.1 2009/08/28 08:20:30 tove Exp $

EAPI=2

#inherit versionator
MODULE_AUTHOR=DAGOLDEN
#MY_P=${PN}-$(delete_version_separator 2)
#S=${WORKDIR}/${MY_P}
inherit perl-module

DESCRIPTION="Build and install Perl modules"

SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# Removing these as hard deps. They are listed as recommended in the Build.PL,
# but end up causing a dep loop since they require module-build to be built.
# ~mcummings 06.16.06
PDEPEND=">=virtual/perl-ExtUtils-CBuilder-0.15
	>=virtual/perl-ExtUtils-ParseXS-1.02"

DEPEND="dev-perl/yaml
	>=virtual/perl-Archive-Tar-1.09
	>=virtual/perl-Test-Harness-3.16"

SRC_TEST="do"
