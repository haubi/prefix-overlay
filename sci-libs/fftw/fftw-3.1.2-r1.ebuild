# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/fftw/fftw-3.1.2-r1.ebuild,v 1.2 2008/07/02 13:20:12 mr_bones_ Exp $

EAPI="prefix"

inherit flag-o-matic eutils toolchain-funcs autotools fortran

DESCRIPTION="Fast C library for the Discrete Fourier Transform"
HOMEPAGE="http://www.fftw.org/"
SRC_URI="http://www.fftw.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="3.0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="altivec doc fortran openmp sse sse2 threads"

pkg_setup() {
	FORTRAN="gfortran ifc g77"
	use fortran && fortran_pkg_setup
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-configure.ac.patch
	epatch "${FILESDIR}"/${P}-openmp.patch
	epatch "${FILESDIR}"/${P}-as-needed.patch

	# fix info file
	sed -e 's/Texinfo documentation system/Libraries/' \
		-i doc/fftw3.info || die "failed to fix info file"
	AT_M4DIR=m4 eautoreconf
	cd "${WORKDIR}"
	mv ${P} ${P}-single
	cp -pPR ${P}-single ${P}-double
	cp -pPR ${P}-single ${P}-longdouble
}

src_compile() {
	# filter -Os according to docs
	replace-flags -Os -O2

	local myconfcommon="--enable-shared
		$(use_with openmp)
		$(use_enable threads)
		$(use_enable fortran)"
	local myconfsingle=""
	local myconfdouble=""
	local myconflongdouble=""

	if use sse2; then
		myconfsingle="${myconfsingle} --enable-sse"
		myconfdouble="${myconfdouble} --enable-sse2"
	elif use sse; then
		myconfsingle="${myconfsingle} --enable-sse"
	fi
	# altivec only helps floats, not doubles
	if use altivec; then
		myconfsingle="${myconfsingle} --enable-altivec"
	fi

	cd "${S}-single"
	econf \
		--enable-float \
		${myconfcommon} \
		${myconfsingle} || \
			die "econf single failed"
	emake || die "emake single failed"

	# the only difference here is no --enable-float
	cd "${S}-double"
	econf \
		${myconfcommon} \
		${myconfdouble} || \
		die "econf double failed"
	emake || die "emake double failed"

	# the only difference here is --enable-long-double
	cd "${S}-longdouble"
	econf \
		--enable-long-double \
		${myconfcommon} \
		${myconflongdouble} || \
		die "econf long double failed"
	emake || die "emake long double failed"
}

src_test () {
	# We want this to be a reasonably quick test, but that is still hard...
	ewarn "This test series will take 30 minutes on a modern 2.5Ghz machine"
	# Do not increase the number of threads, it will not help your performance
	#local testbase="perl check.pl --nthreads=1 --estimate"
	#		${testbase} -${p}d || die "Failure: $n"
	for d in single double longdouble; do
		cd "${S}-${d}"/tests
		einfo "Testing ${PN}-${d}"
		emake -j1 check || die "emake test failed"
	done
}

src_install () {
	# all builds are installed in the same place
	# libs have distinuguished names; include files, docs etc. identical.
	for i in single double longdouble; do
		cd "${S}-${i}"
		emake DESTDIR="${D}" install || die "emake install for ${i} failed"
	done

	# Install documentation.
	cd "${S}-single"
	dodoc AUTHORS ChangeLog NEWS README TODO COPYRIGHT CONVENTIONS || die
	if use doc; then
		cd doc
		insinto /usr/share/doc/${PF}
		doins -r html fftw3.pdf || die "doc install failed"
		insinto /usr/share/doc/${PF}/faq
		doins FAQ/fftw-faq.html/*
	fi
}
