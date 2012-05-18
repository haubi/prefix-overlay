# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/R/R-2.15.0.ebuild,v 1.2 2012/05/03 02:41:39 jdhore Exp $

EAPI=4

inherit bash-completion-r1 autotools eutils flag-o-matic fortran-2 versionator

DESCRIPTION="Language and environment for statistical computing and graphics"
HOMEPAGE="http://www.r-project.org/"
SRC_URI="mirror://cran/src/base/R-2/${P}.tar.gz
	bash-completion? ( mirror://gentoo/R.bash_completion.bz2 )"

LICENSE="|| ( GPL-2 GPL-3 ) LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-macos"
IUSE="bash-completion cairo doc icu java jpeg lapack minimal nls openmp perl png profile readline static-libs tiff tk X"
REQUIRED_USE="png? ( || ( cairo X ) ) jpeg? ( || ( cairo X ) ) tiff? ( || ( cairo X ) )"

CDEPEND="app-arch/bzip2
	app-text/ghostscript-gpl
	dev-libs/libpcre
	virtual/blas
	virtual/fortran
	cairo? ( x11-libs/cairo[X] x11-libs/pango )
	icu? ( dev-libs/icu )
	jpeg? ( virtual/jpeg )
	lapack? ( virtual/lapack )
	perl? ( dev-lang/perl )
	png? ( media-libs/libpng )
	readline? ( sys-libs/readline )
	tk? ( dev-lang/tk )
	X? ( x11-libs/libXmu x11-misc/xdg-utils )"

DEPEND="${CDEPEND}
	virtual/pkgconfig
	doc? (
			virtual/latex-base
			dev-texlive/texlive-fontsrecommended
		 )"

RDEPEND="${CDEPEND}
	( || ( <sys-libs/zlib-1.2.5.1-r1 >=sys-libs/zlib-1.2.5.1-r2[minizip] ) )
	app-arch/xz-utils
	java? ( >=virtual/jre-1.5 )"

RESTRICT="minimal? ( test )"

R_DIR="${EPREFIX}/usr/$(get_libdir)/${PN}"

pkg_setup() {
	if use openmp; then
		FORTRAN_NEED_OPENMP=1
		tc-has-openmp || die "Please enable openmp support in your compiler"
	fi
	fortran-2_pkg_setup
	filter-ldflags -Wl,-Bdirect -Bdirect
	# avoid using existing R installation
	unset R_HOME
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-2.11.1-parallel.patch \
		"${FILESDIR}"/${PN}-2.12.1-ldflags.patch \
		"${FILESDIR}"/${PN}-2.13.1-zlib_header_fix.patch \
		"${FILESDIR}"/${PN}-2.14.1-tiff.patch \
		"${FILESDIR}"/${PN}-2.14.1-rmath-shared.patch \
		"${FILESDIR}"/${PN}-2.14.1-warnings-buffer-overflow.patch \
		"${FILESDIR}"/${PN}-2.14.2-library-writability.patch \
		"${FILESDIR}"/${PN}-2.14.2-prune-package-update.patch

	# fix packages.html for doc (bug #205103)
	sed -i \
		-e "s:../../../library:../../../../$(get_libdir)/R/library:g" \
		src/library/tools/R/Rd.R || die

	# fix Rscript path when installed (bug #221061)
	sed -i \
		-e "s:-DR_HOME='\"\$(rhome)\"':-DR_HOME='\"${R_DIR}\"':" \
		src/unix/Makefile.in || die "sed unix Makefile failed"

	# fix HTML links to manual (bug #273957)
	sed -i \
		-e 's:\.\./manual/:manual/:g' \
		$(grep -Flr ../manual/ doc) || die "sed for HTML links failed"

	use lapack && \
		export LAPACK_LIBS="$(pkg-config --libs lapack)"

	if use X; then
		export R_BROWSER="$(type -p xdg-open)"
		export R_PDFVIEWER="$(type -p xdg-open)"
	fi
	use perl && \
		export PERL5LIB="${S}/share/perl:${PERL5LIB:+:}${PERL5LIB}"

	# don't search /usr/local
	sed -i -e '/FLAGS=.*\/local\//c\: # removed by ebuild' configure.ac || die
	# Fix for Darwin (OS X)
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -e 's:-install_name libR.dylib:-install_name ${libdir}/R/lib/libR.dylib:' \
			-e 's:-install_name libRlapack.dylib:-install_name ${libdir}/R/lib/libRlapack.dylib:' \
			-e 's:-install_name libRblas.dylib:-install_name ${libdir}/R/lib/libRblas.dylib:' \
			-e "/SHLIB_EXT/s/\.so/.dylib/" \
			-i configure.ac || die

		# sort of "undo" 2.14.1-rmath-shared.patch
		sed "s:-Wl,-soname=libRmath.so:-install_name ${EPREFIX}/usr/$(get_libdir)/libRmath.dylib:" \
			-i src/nmath/standalone/Makefile.in || die
	fi

	AT_M4DIR=m4 eaclocal
	eautoconf
}

src_configure() {
	econf \
		--enable-byte-compiled-packages \
		--enable-R-shlib \
		--disable-R-framework \
		--with-system-zlib \
		--with-system-bzlib \
		--with-system-pcre \
		--with-system-xz \
		--with-blas="$(pkg-config --libs blas)" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		rdocdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_enable nls) \
		$(use_enable openmp) \
		$(use_enable profile R-profiling) \
		$(use_enable profile memory-profiling) \
		$(use_enable static-libs static) \
		$(use_enable static-libs R-static-lib) \
		$(use_with cairo) \
		$(use_with icu ICU) \
		$(use_with jpeg jpeglib) \
		$(use_with lapack) \
		$(use_with !minimal recommended-packages) \
		$(use_with png libpng) \
		$(use_with readline) \
		$(use_with tiff libtiff) \
		$(use_with tk tcltk) \
		$(use_with X x)
}

src_compile() {
	export VARTEXFONTS="${T}/fonts"
	emake
	emake -C src/nmath/standalone shared $(use static-libs && echo static)
	use doc && emake info pdf
}

src_install() {
	default
	emake -C src/nmath/standalone DESTDIR="${D}" install

	if use doc; then
		emake DESTDIR="${D}" install-info install-pdf
		dosym ../manual /usr/share/doc/${PF}/html/manual
	fi

	cat > 99R <<-EOF
		LDPATH=${R_DIR}/lib
		R_HOME=${R_DIR}
	EOF
	doenvd 99R
	use bash-completion && dobashcomp "${WORKDIR}"/R.bash_completion

	# The buildsystem has a different understanding of install_names than what
	# we require.  Since it builds modules like shared objects (wrong), many
	# objects (all modules) get an incorrect install_name.  Fixing the build
	# system here is not really trivial.
	if [[ ${CHOST} == *-darwin* ]] ; then
		local mod
		pushd "${ED}"/usr/lib/R > /dev/null
		for mod in $(find . -name "*.dylib") ; do
			mod=${mod#./}
			install_name_tool -id "${EPREFIX}/usr/lib/R/${mod}" \
				"${mod}"
		done
		popd > /dev/null
	fi
}

pkg_postinst() {
	if use java; then
		einfo "Re-initializing java paths for ${P}"
		R CMD javareconf
	fi
}
