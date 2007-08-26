# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/g-cpan/g-cpan-0.15.0-r1.ebuild,v 1.13 2007/08/10 18:04:15 armin76 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="g-cpan: generate and install CPAN modules using portage"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/g-cpan.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
		>=dev-perl/yaml-0.60
		dev-perl/Shell-EnvImporter
		dev-perl/Log-Agent"

src_unpack() {
		unpack ${A}
		cd "${S}"
		epatch "${FILESDIR}"/${P}-prefix.patch
		eprefixify bin/g-cpan lib/Gentoo/Portage.pm
}

src_install() {
		perl-module_src_install
		diropts "-m0755"
		dodir "/var/tmp/g-cpan"
		keepdir "/var/tmp/g-cpan"
		dodir "/var/log/g-cpan"
		keepdir "/var/log/g-cpan"
}

pkg_postinst() {
	elog "You may wish to adjust the permissions on /var/tmp/g-cpan"
	elog "if you have users besides root expecting to use g-cpan."
}
