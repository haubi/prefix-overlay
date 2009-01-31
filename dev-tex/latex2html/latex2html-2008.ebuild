# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/latex2html/latex2html-2008.ebuild,v 1.7 2009/01/30 22:47:19 jer Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="convertor written in Perl that converts LATEX documents to HTML"
SRC_URI="http://saftsack.fs.uni-bayreuth.de/~latex2ht/current/${P}.tar.gz"
HOMEPAGE="http://www.latex2html.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="gif png"

DEPEND="virtual/ghostscript
	virtual/latex-base
	media-libs/netpbm
	dev-lang/perl
	gif? ( media-libs/giflib )
	png? ( media-libs/libpng )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-convert-length.patch"
	epatch "${FILESDIR}/${PN}-perl_name.patch"
	epatch "${FILESDIR}/${PN}-extract-major-version.patch"
	epatch "${FILESDIR}/${PN}-destdir.patch"
	# Dont install old url.sty and other files
	# Bug #240980
	rm -f texinputs/url.sty texinputs/latin9.def || die "failed to remove duplicate latex files"
}

src_compile() {
	sed -ie 's%@PERL@%'"${EPREFIX}"'/usr/bin/perl%g' wrapper/unix.pin || die

	local myconf

	use gif || use png || myconf="${myconf} --disable-images"

	econf --libdir="${EPREFIX}"/usr/$(get_libdir)/latex2html \
		--shlibdir="${EPREFIX}"/usr/$(get_libdir)/latex2html \
		--enable-pk \
		--enable-eps \
		--enable-reverse \
		--enable-pipes \
		--enable-paths \
		--enable-wrapper \
		--with-texpath="${EPREFIX}"/usr/share/texmf-site/tex/latex/html \
		--without-mktexlsr \
		$(use_enable gif) \
		$(use_enable png) \
		${myconf} || die "econf failed"
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc BUGS Changes FAQ LICENSE.orig MANIFEST README* TODO

	# make /usr/share/latex2html sticky
	keepdir /usr/share/latex2html

	# clean the perl scripts up to remove references to the sandbox
	einfo "fixing sandbox references"
	dosed "s:${T}:/tmp:g" /usr/$(get_libdir)/latex2html/pstoimg.pl
	dosed "s:${S}::g" /usr/$(get_libdir)/latex2html/latex2html.pl
	dosed "s:${T}:/tmp:g" /usr/$(get_libdir)/latex2html/cfgcache.pm
	dosed "s:${T}:/tmp:g" /usr/$(get_libdir)/latex2html/l2hconf.pm
}

pkg_postinst() {
	einfo "Running ${EROOT}usr/bin/mktexlsr to rebuild ls-R database...."
	"${EROOT}"usr/bin/mktexlsr
}

pkg_postrm() {
	einfo "Running ${EROOT}usr/bin/mktexlsr to rebuild ls-R database...."
	"${EROOT}"usr/bin/mktexlsr
}
