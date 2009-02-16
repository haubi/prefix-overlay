# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xmlformat/xmlformat-1.04.ebuild,v 1.1 2009/02/15 18:13:30 patrick Exp $

EAPI="prefix"

DESCRIPTION="Reformat XML documents to your custom style"
SRC_URI="http://www.kitebird.com/software/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.kitebird.com/software/xmlformat/"

SLOT="0"
LICENSE="xmlformat"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="ruby? ( virtual/ruby )
	!ruby? ( dev-lang/perl )"
IUSE="ruby doc"

src_install() {
	dobin xmlformat.pl
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl -w' "${ED}"/usr/bin/xmlformat.pl

	if use ruby
	then
		dobin xmlformat.rb
		dosym /usr/bin/xmlformat.rb /usr/bin/xmlformat
		sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/ruby -w' "${ED}"/usr/bin/xmlformat.rb
	else
		dosym /usr/bin/xmlformat.pl /usr/bin/xmlformat
	fi

	dodoc BUGS ChangeLog LICENSE README TODO

	if use doc
	then
		# APIs
		cp -R docs/* ${ED}/usr/share/doc/${PF}
	fi
}

src_test() {
	if use ruby
	then
		./runtest all || die "runtest for ruby failed."
	else
		./runtest -p all || die "runtest for perl failed."
	fi
}
