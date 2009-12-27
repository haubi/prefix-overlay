# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/aspell/aspell-0.60.6.ebuild,v 1.12 2009/12/26 20:36:02 pva Exp $

# N.B. This is before inherit of autotools, as autotools.eclass adds the
# relevant dependencies to DEPEND.
WANT_AUTOMAKE="1.10"

inherit libtool eutils flag-o-matic autotools

DESCRIPTION="A spell checker replacement for ispell"
HOMEPAGE="http://aspell.net/"
SRC_URI="mirror://gnu/aspell/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="gpm nls examples"
# Note; app-text/aspell-0.6 and app-dicts/aspell-en-0.6 must go stable together

# Build PDEPEND from list of language codes provided in the tree.
# The PDEPEND string is static - this code just makes it easier to maintain.
def="app-dicts/aspell-en"
for l in \
	"af" "be" "bg" "br" "ca" "cs" "cy" "da" "de" "el" \
	"en" "eo" "es" "et" "fi" "fo" "fr" "ga" "gl" "he" \
	"hr" "is" "it" "nl" "no" "pl" "pt" "ro" \
	"ru" "sk" "sl" "sr" "sv" "uk" "vi"; do
	dep="linguas_${l}? ( app-dicts/aspell-${l} )"
	[[ -z ${PDEPEND} ]] &&
		PDEPEND="${dep}" ||
		PDEPEND="${PDEPEND}
${dep}"
	def="!linguas_${l}? ( ${def} )"
	IUSE="${IUSE} linguas_${l}"
done
PDEPEND="${PDEPEND}
${def}"

RDEPEND=">=sys-libs/ncurses-5.2
	gpm? ( sys-libs/gpm )
	nls? ( virtual/libintl )"
# English dictionary 0.5 is incompatible with aspell-0.6

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/aspell-0.60.3-templateinstantiations.patch"
	epatch "${FILESDIR}/${PN}-0.60.5-nls.patch"

	epatch "${FILESDIR}"/${PN}-0.60.5-solaris.patch
	epatch "${FILESDIR}"/${PN}-0.60.6-darwin-bundles.patch

	rm m4/lt* m4/libtool.m4
	eautoreconf
	elibtoolize --reverse-deps
}

src_compile() {
	use gpm && append-ldflags -lgpm
	filter-flags -fno-rtti
	filter-flags -fvisibility=hidden #77109
	filter-flags -maltivec -mabi=altivec
	use ppc && append-flags -mno-altivec

	econf \
		$(use_enable nls) \
		--disable-static \
		--sysconfdir="${EPREFIX}"/etc/aspell \
		--enable-docdir="${EPREFIX}"/usr/share/doc/${PF}

	emake || die "compilation failed"
}

src_install() {
	dodoc README* TODO || die "installing docs failed"

	emake DESTDIR="${D}" install || die "installation failed"
	mv "${ED}"/usr/share/doc/${PF}/man-html "${ED}"/usr/share/doc/${PF}/html
	mv "${ED}"/usr/share/doc/${PF}/man-text "${ED}"/usr/share/doc/${PF}/text

	# install ispell/aspell compatibility scripts
	exeinto /usr/bin
	newexe scripts/ispell ispell-aspell
	newexe scripts/spell spell-aspell

	if use examples ; then
		cd examples
		make clean || die
		docinto examples
		dodoc "${S}"/examples/* || die "installing examples failed"
	fi
}

pkg_postinst() {
	elog "You will need to install a dictionary now.  Please choose an"
	elog "aspell-<LANG> dictionary from the app-dicts category"
	elog "After installing an aspell dictionary for your language(s),"
	elog "You may use the aspell-import utility to import your personal"
	elog "dictionaries from ispell, pspell and the older aspell"
}
