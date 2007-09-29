# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/sbcl/sbcl-1.0.6-r2.ebuild,v 1.6 2007/09/27 11:57:09 hkbst Exp $

EAPI="prefix"

inherit common-lisp-common-3 eutils flag-o-matic

#same order as http://www.sbcl.org/platform-table.html
BV_X86=1.0.7
BV_AMD64=1.0.7
BV_PPC=1.0
BV_SPARC=0.9.17
BV_ALPHA=0.9.12
BV_MIPS=0.9.12
BV_MIPSEL=0.9.12

BV_PPC_MACOS=1.0.2
BV_X86_MACOS=1.0.7
BV_X86_SOLARIS=0.9.14

DESCRIPTION="Steel Bank Common Lisp (SBCL) is an implementation of ANSI Common Lisp."
HOMEPAGE="http://sbcl.sourceforge.net/"
SRC_URI="mirror://sourceforge/sbcl/${P}-source.tar.bz2
	x86? ( mirror://sourceforge/sbcl/${PN}-${BV_X86}-x86-linux-binary.tar.bz2 )
	amd64? ( mirror://sourceforge/sbcl/${PN}-${BV_AMD64}-x86-64-linux-binary.tar.bz2 )
	ppc? ( mirror://sourceforge/sbcl/${PN}-${BV_PPC}-powerpc-linux-binary.tar.bz2 )
	sparc? ( mirror://sourceforge/sbcl/${PN}-${BV_SPARC}-sparc-linux-binary.tar.bz2 )
	alpha? ( mirror://sourceforge/sbcl/${PN}-${BV_ALPHA}-alpha-linux-binary.tar.bz2 )
	mips? ( !cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPS}-mips-linux-binary.tar.bz2 ) )
	mips? ( cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPSEL}-mipsel-linux-binary.tar.bz2 ) )
	ppc-macos? ( mirror://sourceforge/sbcl/${PN}-${BV_PPC_MACOS}-powerpc-darwin-binary.tar.bz2 )
	x86-macos? ( mirror://sourceforge/sbcl/${PN}-${BV_X86_MACOS}-x86-darwin-binary.tar.bz2 )
	x86-solaris? ( mirror://sourceforge/sbcl/${PN}-${BV_X86_SOLARIS}-x86-solaris-binary.tar.gz)
"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64 ~mips ~ppc-macos ~x86 ~x86-macos ~x86-solaris"

IUSE="ldb source threads unicode doc"

DEPEND="doc? ( sys-apps/texinfo )"

PROVIDE="virtual/commonlisp"

pkg_setup() {
	if built_with_use sys-devel/gcc hardened && gcc-config -c | grep -qv vanilla; then
		eerror "So-called \"hardened\" compiler features are incompatible with SBCL. You"
		eerror "must use gcc-config to select a profile with non-hardened features"
		eerror "(the \"vanilla\" profile) and \"source /etc/profile\" before continuing."
		die
	fi
	if use !prefix && (use x86 || use amd64) && has_version "<sys-libs/glibc-2.6" \
		&& ! built_with_use sys-libs/glibc nptl; then
		eerror "Building SBCL without NPTL support on at least x86 and amd64"
		eerror "architectures is not a supported configuration in Gentoo.  Please"
		eerror "refer to Bug #119016 for more information."
		die
	fi
	if (use ppc-macos || use ppc) && use ldb; then
		ewarn "Building SBCL on PPC with LDB support is not a supported configuration"
		ewarn "in Gentoo.	Please refer to Bug #121830 for more information."
		ewarn "Continuing with LDB support disabled."
	fi
}

enable_sbcl_feature() {
	echo "(enable $1)" >> "${S}/customize-target-features.lisp"
}

disable_sbcl_feature() {
	echo "(disable $1)" >> "${S}/customize-target-features.lisp"
}

sbcl_apply_features() {
	cat > "${S}/customize-target-features.lisp" <<'EOF'
(lambda (list)
  (flet ((enable (x)
		   (pushnew x list))
		 (disable (x)
		   (setf list (remove x list))))
EOF
	if use x86 || use amd64; then
		use threads && enable_sbcl_feature ":sb-thread"
	fi
	if (use ppc-macos || use ppc) && use ldb; then
		ewarn "Excluding LDB support for ppc."
	else
		use ldb && enable_sbcl_feature ":sb-ldb"
	fi
	disable_sbcl_feature ":sb-test"
	! use unicode && disable_sbcl_feature ":sb-unicode"
	cat >> "${S}/customize-target-features.lisp" <<'EOF'
	)
  list)
EOF
}

src_unpack() {
	unpack ${A}
	mv sbcl-*-* sbcl-binary

	pushd "${S}"
	epatch ${FILESDIR}/disable-tests-gentoo.patch || die
	use source && epatch "${FILESDIR}/vanilla-module-install-source-gentoo.patch"
	epatch "${FILESDIR}"/${P}-solaris.patch || die
	popd
	sed -i "s,/lib,${EPREFIX}/$(get_libdir),g" ${S}/install.sh
	sed -i "s,/usr/local/lib,${EPREFIX}/usr/$(get_libdir),g" \
		${S}/src/runtime/runtime.c # #define SBCL_HOME ...

	# applying customizations
	sbcl_apply_features

	find "${S}" -type f -name .cvsignore -print0 | xargs -0 rm -f
	find "${S}" -depth -type d -name CVS -print0 | xargs -0 rm -rf
	find "${S}" -type f -name \*.c -print0 | xargs -0 chmod 644
}

src_compile() {
	local bindir="${WORKDIR}/sbcl-binary"

	filter-ldflags -Wl,--as-needed --as-needed # see Bug #132992

	# clear the environment to get rid of non-ASCII strings, see bug 174702
	env - PATH="${bindir}/src/runtime:${PATH}" SBCL_HOME="${bindir}/output" GNUMAKE=make ./make.sh \
		"sbcl --sysinit /dev/null --userinit /dev/null	--disable-debugger --core ${bindir}/output/sbcl.core" \
		|| die "make failed"

	if use doc; then
		cd "${S}/doc/manual"
		make info html || die "make info html failed"
		cd "${S}/doc/internals"
		make html || die "make html failed"
	fi
}

src_install() {
	unset SBCL_HOME
	dodir /etc/
	cat > "${ED}/etc/sbclrc" <<EOF
;;; The following is required if you want source location functions to
;;; work in SLIME, for example.

(setf (logical-pathname-translations "SYS")
	'(("SYS:SRC;**;*.*.*" #p"${EPREFIX}/usr/$(get_libdir)/sbcl/src/**/*.*")
	  ("SYS:CONTRIB;**;*.*.*" #p"${EPREFIX}/usr/$(get_libdir)/sbcl/**/*.*")))
EOF
	dodir /usr/share/man
	dodir /usr/share/doc/${PF}
	INSTALL_ROOT="${ED}/usr" DOC_DIR="${ED}/usr/share/doc/${PF}" sh install.sh || die "install.sh failed"

	doman doc/sbcl-asdf-install.1

	dodoc BUGS CREDITS INSTALL NEWS OPTIMIZATIONS PRINCIPLES README STYLE SUPPORT TLA TODO

	if use doc; then
		dohtml doc/html/*
		doinfo "${S}/doc/manual/"*.info*
		dohtml -r "${S}/doc/internals/sbcl-internals"
	fi

	if use source; then
		# install the SBCL source
		cp -pPR "${S}/src" "${ED}/usr/$(get_libdir)/sbcl"
		find "${ED}/usr/$(get_libdir)/sbcl/src" -type f -name \*.fasl -print0 | xargs -0 rm -f
	fi

	impl-save-timestamp-hack sbcl
}

pkg_postinst() {
	standard-impl-postinst sbcl
}

pkg_postrm() {
	standard-impl-postrm sbcl /usr/bin/sbcl
}
