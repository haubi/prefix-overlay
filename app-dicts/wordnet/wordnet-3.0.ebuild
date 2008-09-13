# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/wordnet/wordnet-3.0.ebuild,v 1.3 2008/09/12 19:36:30 pva Exp $

EAPI="prefix"

inherit flag-o-matic autotools

DESCRIPTION="A lexical database for the English language"
HOMEPAGE="http://wordnet.princeton.edu/"
SRC_URI="ftp://ftp.cogsci.princeton.edu/pub/wordnet/${PV}/WordNet-${PV}.tar.gz"
LICENSE="Princeton"

SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"

# In contrast to what the configure script seems to imply, Tcl/Tk is NOT optional.
# cf. bug 163478 for details. (Yes, it's about 2.1 but it's still the same here.)
DEPEND="dev-lang/tcl
		dev-lang/tk"
RDEPEND="${DEPEND}"

S=${WORKDIR}/WordNet-${PV}

src_unpack() {
	unpack ${A}
	# Don't install into PREFIX/dict but PREFIX/share/wordnet/dict
	epatch "${FILESDIR}/${P}-dict-location.patch"
	# Fixes bug 130024, make an additional shared lib
	epatch "${FILESDIR}/${P}-shared-lib.patch"
	# Don't install the docs directly into PREFIX/doc but PREFIX/doc/PN
	epatch "${FILESDIR}/${P}-docs-path.patch"

	cd "${S}"

	# Don't install all the extra docs (html, pdf, ps) without doc USE flag.
	use doc || sed -i -e "s:SUBDIRS =.*:SUBDIRS = man:" doc/Makefile.am

	rm -f configure
	eautoreconf
}

src_compile() {
	append-flags -DUNIX -I${T}/usr/include

	MAKEOPTS="-e"
	PLATFORM=linux WN_ROOT="${T}/usr" \
	WN_DICTDIR="${T}/usr/share/wordnet/dict" \
	WN_MANDIR="${T}/usr/share/man" \
	WN_DOCDIR="${T}/usr/share/doc/wordnet-${PV}" \
	WNHOME="/usr/share/wordnet" \
	econf \
		--with-tcl="${EPREFIX}"/usr/$(get_libdir) \
		--with-tk="${EPREFIX}"/usr/$(get_libdir)
	emake || die "emake Failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	dodoc AUTHORS ChangeLog INSTALL README || die "dodoc failed"
}
