# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.12.7.ebuild,v 1.1 2011/07/07 07:42:59 hwoarang Exp $

EAPI="3"

inherit autotools libtool

DESCRIPTION="A TLS 1.2 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"

if [[ "${PV}" == *pre* ]]; then
	SRC_URI="http://daily.josefsson.org/${P%.*}/${P%.*}-${PV#*pre}.tar.gz"
else
	MINOR_VERSION="${PV#*.}"
	MINOR_VERSION="${MINOR_VERSION%%.*}"
	if [[ $((MINOR_VERSION % 2)) == 0 ]]; then
		#SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.bz2"
		SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"
	else
		SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.bz2"
	fi
	unset MINOR_VERSION
fi

# LGPL-2.1 for libgnutls library and GPL-3 for libgnutls-extra library.
LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="bindist +cxx doc examples guile lzo +nettle nls test zlib"

# lib/m4/hooks.m4 says that GnuTLS uses a fork of PaKChoiS.
RDEPEND=">=dev-libs/libtasn1-0.3.4
	nls? ( virtual/libintl )
	guile? ( >=dev-scheme/guile-1.8[networking] )
	nettle? ( >=dev-libs/nettle-2.1[gmp] )
	!nettle? ( >=dev-libs/libgcrypt-1.4.0 )
	zlib? ( >=sys-libs/zlib-1.2.3.1 )
	!bindist? ( lzo? ( >=dev-libs/lzo-2 ) )"
DEPEND="${RDEPEND}
	sys-devel/libtool
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )
	test? ( app-misc/datefudge )"

S="${WORKDIR}/${P%_pre*}"

pkg_setup() {
	if use lzo && use bindist; then
		ewarn "lzo support is disabled for binary distribution of GnuTLS due to licensing issues."
	fi
}

src_prepare() {
	# tests/suite directory is not distributed.
	sed -e 's|AC_CONFIG_FILES(\[tests/suite/Makefile\])|:|' -i configure.ac

	sed -e 's/imagesdir = $(infodir)/imagesdir = $(htmldir)/' -i doc/Makefile.am

	local dir
	for dir in m4 lib/m4 libextra/m4; do
		rm -f "${dir}/lt"* "${dir}/libtool.m4"
	done
	find . -name ltmain.sh -exec rm {} \;
	for dir in . lib libextra; do
		pushd "${dir}" > /dev/null
		eautoreconf
		popd > /dev/null
	done

	# Use sane .so versioning on FreeBSD.
	elibtoolize
}

src_configure() {
	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"
	[[ "${VALGRIND_TESTS}" != "1" ]] && myconf+=" --disable-valgrind-tests"

	econf --htmldir="${EPREFIX}"/usr/share/doc/${P}/html \
		$(use_enable cxx) \
		$(use_enable doc gtk-doc) \
		$(use_enable guile) \
		$(use_with !nettle libgcrypt) \
		$(use_enable nls) \
		$(use_with zlib) \
		${myconf}
}

src_test() {
	if has_version dev-util/valgrind && [[ "${VALGRIND_TESTS}" != "1" ]]; then
		elog
		elog "You can set VALGRIND_TESTS=\"1\" to enable Valgrind tests."
		elog
	fi

	default
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README THANKS doc/TODO || die "dodoc failed"

	if use doc; then
		dodoc doc/gnutls.{pdf,ps} || die "dodoc failed"
		dohtml doc/gnutls.html || die "dohtml failed"
	fi

	if use examples; then
		docinto examples
		dodoc doc/examples/*.c || die "dodoc failed"
	fi
}
