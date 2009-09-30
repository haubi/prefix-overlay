# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/tcsh/tcsh-6.16.ebuild,v 1.8 2009/04/10 19:52:35 grobian Exp $

inherit eutils flag-o-matic autotools prefix

CONFVER="1.8"

MY_P="${P}.00"
DESCRIPTION="Enhanced version of the Berkeley C shell (csh)"
HOMEPAGE="http://www.tcsh.org/"
SRC_URI="ftp://ftp.astron.com/pub/tcsh/${MY_P}.tar.gz
	http://www.gentoo.org/~grobian/distfiles/tcsh-gentoo-patches-r${CONFVER}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="perl catalogs"
RESTRICT="test"

# we need gettext because we run autoconf
DEPEND=">=sys-libs/ncurses-5.1
	sys-devel/gettext
	perl? ( dev-lang/perl )"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}
CONFDIR=${WORKDIR}/tcsh-gentoo-patches-r${CONFVER}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${MY_P/16/14}"-debian-dircolors.patch # bug #120792
	epatch "${FILESDIR}"/${PN}-6.14-makefile.patch # bug #151951
	epatch "${FILESDIR}"/${PN}-6.14-use-ncurses.patch
	eautoreconf

	if use catalogs ; then
		einfo "enabling NLS catalogs support..."
		sed -i -e "s/#undef NLS_CATALOGS/#define NLS_CATALOGS/" \
			config_f.h || die
		eend $?
	fi

	# unify ECHO behaviour
	echo "#undef ECHO_STYLE" >> config_f.h
	echo "#define ECHO_STYLE      BOTH_ECHO" >> config_f.h

	eprefixify "${CONFDIR}"/*
	# activate the right default PATH
	if [[ -z ${EPREFIX} ]] ; then
		sed -i \
			-e 's/^#MAIN//' -e '/^#PREFIX/d' \
			"${CONFDIR}"/csh.login || die
	else
		sed -i \
			-e 's/^#PREFIX//' -e '/^#MAIN/d' \
			"${CONFDIR}"/csh.login || die
	fi
}

src_compile() {
	# make tcsh look and live along the lines of the prefix
	append-flags -D_PATH_DOTCSHRC="'"'"${EPREFIX}/etc/csh.cshrc"'"'"
	append-flags -D_PATH_DOTLOGIN="'"'"${EPREFIX}/etc/csh.login"'"'"
	append-flags -D_PATH_DOTLOGOUT="'"'"${EPREFIX}/etc/csh.logout"'"'"
	append-flags -D_PATH_USRBIN="'"'"${EPREFIX}/usr/bin"'"'"
	append-flags -D_PATH_BIN="'"'"${EPREFIX}/bin"'"'"

	econf --prefix="${EPREFIX:-/}" || die "econf failed"
	emake || die "compile problem"
}

src_install() {
	emake DESTDIR="${D}" install install.man || die

	if use perl ; then
		perl tcsh.man2html tcsh.man || die
		dohtml tcsh.html/*.html
	fi

	insinto /etc
	doins \
		"${CONFDIR}"/csh.cshrc \
		"${CONFDIR}"/csh.login

	dodoc FAQ Fixes NewThings Ported README WishList Y2K

	# bug #119703: add csh -> tcsh symlink
	dosym /bin/tcsh /bin/csh
}
