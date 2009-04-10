# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/readline/readline-6.0.ebuild,v 1.4 2009/02/24 08:57:47 kumba Exp $

EAPI="prefix"

inherit autotools eutils multilib toolchain-funcs flag-o-matic

# Official patches
# See ftp://ftp.cwru.edu/pub/bash/readline-6.0-patches/
PLEVEL=${PV##*_p}
MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
[[ ${PV} != *_p* ]] && PLEVEL=0
patches() {
	[[ ${PLEVEL} -eq 0 ]] && return 1
	local opt=$1
	eval set -- {1..${PLEVEL}}
	set -- $(printf "${PN}${MY_PV/\.}-%03d " "$@")
	if [[ ${opt} == -s ]] ; then
		echo "${@/#/${DISTDIR}\/}"
	else
		local u
		for u in ftp://ftp.cwru.edu/pub/bash mirror://gnu/${PN} ; do
			printf "${u}/${PN}-${MY_PV}-patches/%s " "$@"
		done
	fi
}

DESCRIPTION="Another cute console display library"
HOMEPAGE="http://cnswww.cns.cwru.edu/php/chet/readline/rltop.html"
SRC_URI="mirror://gnu/${PN}/${MY_P}.tar.gz $(patches)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

# We must be certain that we have a bash that is linked
# to its internal readline, else we may get problems.
RDEPEND=">=sys-libs/ncurses-5.2-r2"
DEPEND="${RDEPEND}
	>=app-shells/bash-2.05b-r2"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz

	cd "${S}"
	[[ ${PLEVEL} -gt 0 ]] && epatch $(patches -s)
	# missing patch for 'support/shlib-install' in p12 (netbsd, aix5, interix).
#	epatch "${FILESDIR}"/${PN}-5.2_p12-shlib-install.patch

	epatch "${FILESDIR}"/${PN}-5.0-no_rpath.patch
	epatch "${FILESDIR}"/${PN}-6.0-rlfe-build.patch #151174
	epatch "${FILESDIR}"/${PN}-5.2-no-ignore-shlib-errors.patch #216952

	epatch "${FILESDIR}"/${PN}-5.1-rlfe-extern.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-aix-eff_uid.patch
	epatch "${FILESDIR}"/${PN}-5.2-rlfe-hpux.patch
#	epatch "${FILESDIR}"/${PN}-5.2-rlfe-irix.patch #209595
	epatch "${FILESDIR}"/${PN}-5.2-interix.patch
	epatch "${FILESDIR}"/${PN}-5.2-ia64hpux.patch
#	epatch "${FILESDIR}"/${PN}-5.2-aixdll.patch
#	epatch "${FILESDIR}"/${PN}-5.2-mint.patch
#	epatch "${FILESDIR}"/${PN}-5.2-solaris-fPIC.patch
#	[[ ${CHOST} == *-darwin9 ]] && epatch "${FILESDIR}"/${PN}-5.2-darwin9-rlfe.patch

	# force ncurses linking #71420
	sed -i -e 's:^SHLIB_LIBS=:SHLIB_LIBS=-lncurses:' support/shobj-conf || die "sed"

	# the bundled rlfe had its configure.in updated, but no one actually
	# ran autoconf to have the configure file updated
	ln -s ../.. examples/rlfe/readline
	cd examples/rlfe
	eautoconf
}

src_compile() {
	append-cppflags -D_GNU_SOURCE

	econf --with-curses || die
	emake || die

	if ! tc-is-cross-compiler ; then
		cd examples/rlfe
		append-ldflags -Lreadline
		econf || die
		emake || die "make rlfe failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	gen_usr_ldscript -a readline history #4411

	if ! tc-is-cross-compiler; then
		dobin examples/rlfe/rlfe || die
	fi

	dodoc CHANGELOG CHANGES README USAGE NEWS
	docinto ps
	dodoc doc/*.ps
	dohtml -r doc
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 4) #29865
	preserve_old_lib /$(get_libdir)/lib{history,readline}$(get_libname 5) #29865
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 4)
	preserve_old_lib_notify /$(get_libdir)/lib{history,readline}$(get_libname 5)
}
