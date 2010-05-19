# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lisp/sbcl/sbcl-1.0.36-r1.ebuild,v 1.3 2010/03/26 01:40:04 pchrist Exp $

EAPI=3

inherit multilib eutils

#same order as http://www.sbcl.org/platform-table.html
BV_X86=1.0.36
BV_AMD64=1.0.29
BV_PPC=1.0.28
BV_SPARC=1.0.28
BV_ALPHA=1.0.28
BV_MIPS=1.0.23
BV_MIPSEL=1.0.28

# for Mac OS X: 1.0.23 binaries are broken on Tiger (Bus Error)
BV_PPC_MACOS=1.0.2
BV_X86_MACOS=1.0.2
BV_X86_SOLARIS=1.0.23


DESCRIPTION="Steel Bank Common Lisp (SBCL) is an implementation of ANSI Common Lisp."
HOMEPAGE="http://sbcl.sourceforge.net/"
SRC_URI="mirror://sourceforge/sbcl/${P}-source.tar.bz2
	x86? ( mirror://sourceforge/sbcl/${PN}-${BV_X86}-x86-linux-binary.tar.bz2 )
	amd64? ( mirror://sourceforge/sbcl/${PN}-${BV_AMD64}-x86_64-linux-binary-r2.tar.bz2 )
	ppc? ( mirror://sourceforge/sbcl/${PN}-${BV_PPC}-powerpc-linux-binary.tar.bz2 )
	sparc? ( mirror://sourceforge/sbcl/${PN}-${BV_SPARC}-sparc-linux-binary.tar.bz2 )
	alpha? ( mirror://sourceforge/sbcl/${PN}-${BV_ALPHA}-alpha-linux-binary.tar.bz2 )
	mips? ( !cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPS}-mips-linux-binary.tar.bz2 ) )
	mips? ( cobalt? ( mirror://sourceforge/sbcl/${PN}-${BV_MIPSEL}-mipsel-linux-binary.tar.bz2 ) )
	ppc-macos? ( mirror://sourceforge/sbcl/${PN}-${BV_PPC_MACOS}-powerpc-darwin-binary.tar.bz2 )
	x86-macos? ( mirror://sourceforge/sbcl/${PN}-${BV_X86_MACOS}-x86-darwin-binary.tar.bz2 )
	x86-solaris? ( mirror://sourceforge/sbcl/${PN}-${BV_X86_SOLARIS}-x86-solaris-binary.tar.gz )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="ldb source +threads +unicode doc cobalt"

DEPEND="doc? ( sys-apps/texinfo || ( >=media-gfx/graphviz-2.20[png] >=media-gfx/graphviz-2.24.0 ) )"
RDEPEND="elibc_glibc? ( !prefix? ( >=sys-libs/glibc-2.3 || ( <sys-libs/glibc-2.6[nptl] >=sys-libs/glibc-2.6 ) ) )"
PDEPEND="dev-lisp/gentoo-init"

PROVIDE="virtual/commonlisp"

# Disable warnings about executable stacks, as this won't be fixed soon by upstream
QA_EXECSTACK="usr/bin/sbcl"

pkg_setup() {
	if has_version sys-devel/gcc && built_with_use sys-devel/gcc hardened && gcc-config -c | grep -qv vanilla; then
		eerror "So-called \"hardened\" compiler features are incompatible with SBCL. You"
		eerror "must use gcc-config to select a profile with non-hardened features"
		eerror "(the \"vanilla\" profile) and \"source /etc/profile\" before continuing."
		die
	fi
	ewarn "This is a new ebuild, based on older ones, but with some internal"
	ewarn "changes. If it fails, please, file a bug without hesitation."
}

CONFIG="${S}/customize-target-features.lisp"
ENVD="${T}/50sbcl"

usep() {
	use ${1} && echo "true" || echo "false"
}

sbcl_feature() {
	echo "$( [[ ${1} == "true" ]] && echo "(enable ${2})" || echo "(disable ${2})")" >> "${CONFIG}"
}

sbcl_apply_features() {
	cat > "${CONFIG}" <<'EOF'
(lambda (list)
  (flet ((enable  (x) (pushnew x list))
		 (disable (x) (setf list (remove x list))))
EOF
	if use x86 || use amd64; then
		sbcl_feature "$(usep threads)" ":sb-thread"
	fi
	sbcl_feature "$(usep ldb)" ":sb-ldb"
	sbcl_feature "false" ":sb-test"
	sbcl_feature "$(usep unicode)" ":sb-unicode"
	cat >> "${CONFIG}" <<'EOF'
	)
  list)
EOF
	cat "${CONFIG}"
}

src_unpack() {
	unpack ${A}
	mv sbcl-*-* sbcl-binary
	cd "${S}"
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.0.6-solaris.patch
	epatch "${FILESDIR}"/${PN}-1.0.36-introspect-tests.patch

	use source && sed 's%"$(BUILD_ROOT)%$(MODULE).lisp "$(BUILD_ROOT)%' -i contrib/vanilla-module.mk

	sed "s,/lib,/$(get_libdir),g" -i install.sh
	sed  "s,/usr/local/lib,${EPREFIX}/usr/$(get_libdir),g" -i src/runtime/runtime.c # #define SBCL_HOME ...
	sed  "s,/etc/sbclrc,${EPREFIX}/etc/sbclrc,g" -i src/code/toplevel.lisp # change location of /etc/sbclrc ...

	find . -type f -name .cvsignore -delete
	epatch  "${FILESDIR}/${P}-fix_linux-os-c.patch"
	#fix CFLAGS and LDFLAGS
	pushd src/runtime
	sed -i -e "s/CFLAGS = -g -Wall -Wsign-compare -O3/CFLAGS =${CFLAGS}/g" GNUmakefile
	sed -i -e "s/CPPFLAGS = -I./CPPFLAGS = -I. ${CXXFLAGS}/g" GNUmakefile
	sed -i -e "s/LINKFLAGS = -g/LINKFLAGS = -g ${LDFLAGS}/g" GNUmakefile
	sed -i -e 's/-fno-omit-frame-pointer/ /g' Config*
	popd
}

src_configure() {
	# customizing SBCL version as per
	# http://sbcl.cvs.sourceforge.net/sbcl/sbcl/doc/PACKAGING-SBCL.txt?view=markup
	echo -e ";;; Auto-generated by Gentoo\n\"gentoo-${PR}\"" > branch-version.lisp-expr

	# applying customizations
	sbcl_apply_features
}

src_compile() {
	local bindir="${WORKDIR}"/sbcl-binary

	# clear the environment to get rid of non-ASCII strings, see bug 174702
	# set HOME for paludis
	env - HOME="${T}" \
		PATH="${bindir}/src/runtime:${PATH}" SBCL_HOME="${bindir}/output" GNUMAKE=make ./make.sh \
		"sbcl --no-sysinit --no-userinit --disable-debugger --core ${bindir}/output/sbcl.core" \
		|| die "make failed"

	# need to set HOME because libpango(used by graphviz) complains about it
	if use doc; then
		env - HOME="${T}" make -C doc/manual info html || die "Cannot build manual"
		env - HOME="${T}" make -C doc/internals info html || die "Cannot build internal docs"
	fi
}

src_test() {
	ewarn "Unfortunately, it is known that some tests fail eg."
	ewarn "run-program.impure.lisp. This is an issue of the upstream's"
	ewarn "development and not of Gentoo's side. Please, before filing"
	ewarn "any bug(s) search for older submissions. Thank you."
	time ( cd tests && sh run-tests.sh )
}

src_install() {
	# install system-wide initfile
	dodir /etc/
	cat > "${ED}"/etc/sbclrc <<EOF
;;; The following is required if you want source location functions to
;;; work in SLIME, for example.

(setf (logical-pathname-translations "SYS")
	'(("SYS:SRC;**;*.*.*" #p"${EPREFIX}/usr/$(get_libdir)/sbcl/src/**/*.*")
	  ("SYS:CONTRIB;**;*.*.*" #p"${EPREFIX}/usr/$(get_libdir)/sbcl/**/*.*")))

;;; Setup ASDF
(load "${EPREFIX}/etc/gentoo-init.lisp")
EOF

	# Install documentation
	unset SBCL_HOME
	INSTALL_ROOT="${ED}/usr" DOC_DIR="${ED}/usr/share/doc/${PF}" \
		sh install.sh || die "install.sh failed"

	# rm empty directories lest paludis complain about this
	# rmdir "${ED}"/usr/$(get_libdir)/sbcl/{site-systems,sb-posix/test-lab,sb-cover/test-output} 2>/dev/null
	find "${ED}" -empty -type d -exec rmdir -v {} +

	doman doc/sbcl-asdf-install.1

	if use doc; then
		dodoc OPTIMIZATIONS PRINCIPLES README STYLE TLA TODO STYLE
		pushd doc
		dohtml -r internals/sbcl-internals
		dodoc internals-notes/*
		doinfo internals/sbcl-internals.info
		popd
	else
		rm -Rv "${ED}/usr/share/doc/${PF}"
	fi

	# install the SBCL source
	if use source; then
		./clean.sh
		cp -a -v src "${ED}/usr/$(get_libdir)/sbcl/"
	fi

	# necessary for running newly-saved images
	echo "SBCL_HOME=${EPREFIX}/usr/$(get_libdir)/${PN}" > "${ENVD}"
	echo "SBCL_SOURCE_ROOT=${EPREFIX}/usr/$(get_libdir)/${PN}/src" >> "${ENVD}"
	doenvd "${ENVD}"
}
