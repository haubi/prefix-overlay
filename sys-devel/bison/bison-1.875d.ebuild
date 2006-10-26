# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/bison/bison-1.875d.ebuild,v 1.11 2005/03/09 02:12:08 vapier Exp $

EAPI="prefix"

inherit toolchain-funcs flag-o-matic eutils

DESCRIPTION="A yacc-compatible parser generator"
HOMEPAGE="http://www.gnu.org/software/bison/bison.html"
SRC_URI="ftp://alpha.gnu.org/pub/gnu/bison/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="nls static"

DEPEND="sys-devel/m4
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.32-extfix.patch
}

src_compile() {
	# Bug 39842 says that bison segfaults when built on amd64 with
	# optimizations.  This will probably be fixed in a future gcc
	# version, but for the moment just disable optimizations for that
	# arch (04 Feb 2004 agriffis)
	[ "$ARCH" == "amd64" ] && append-flags -O0

	# Bug 29017 says that bison has compile-time issues with
	# -march=k6* prior to 3.4CVS.  Use -march=i586 instead
	# (04 Feb 2004 agriffis)
	#
	if (( $(gcc-major-version) == 3 && $(gcc-minor-version) < 4 )) ; then
		replace-cpu-flags k6 k6-1 k6-2 i586
	fi

	econf $(use_enable nls) || die
	use static && append-ldflags -static
	emake || die
}

src_install() {
	make DESTDIR="${ED}" \
		datadir=${EPREFIX}/usr/share \
		mandir=${EPREFIX}/usr/share/man \
		infodir=${EPREFIX}/usr/share/info \
		install || die

	# This one is installed by dev-util/yacc
	mv "${ED}"/usr/bin/yacc "${ED}"/usr/bin/yacc.bison || die

	# We do not need this.
	rm -f "${ED}"/usr/lib/liby.a

	dodoc AUTHORS NEWS ChangeLog README REFERENCES OChangeLog doc/FAQ
}

pkg_postinst() {
	if [[ ! -e ${EROOT}/usr/bin/yacc ]] ; then
		ln -s yacc.bison "${EROOT}"/usr/bin/yacc
	fi
}
