# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sed/sed-4.2.ebuild,v 1.4 2009/05/29 19:41:36 flameeyes Exp $

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"
SRC_URI="mirror://gnu/sed/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl nls static"

RDEPEND="nls? ( virtual/libintl )
	acl? ( virtual/acl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_bootstrap_sed() {
	# make sure system-sed works #40786
	export NO_SYS_SED=""
	if ! type -p sed > /dev/null ; then
		NO_SYS_SED="!!!"
		./bootstrap.sh || die "couldnt bootstrap"
		cp sed/sed "${T}"/ || die "couldnt copy"
		export PATH="${PATH}:${T}"
		make clean || die "couldnt clean"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-4.1.5-alloca.patch
	epatch "${FILESDIR}"/${PN}-4.1.4-aix-malloc.patch
	epatch "${FILESDIR}"/${PN}-4.1.5-regex-nobool.patch
	# don't use sed here if we have to recover a broken host sed
}

src_compile() {
	src_bootstrap_sed
	# this has to be after the bootstrap portion
	sed -i \
		-e '/docdir =/s:=.*/doc:= $(datadir)/doc/'${PF}'/html:' \
		doc/Makefile.in || die "sed html doc"

	local myconf= bindir="${EPREFIX}"/bin
	if ! use userland_GNU ; then
		myconf="--program-prefix=g"
		bindir="${EPREFIX}"/usr/bin
	fi

	use static && append-ldflags -static
	econf \
		--bindir="${bindir}" \
		$(use_enable acl) \
		$(use_enable nls) \
		${myconf}
	emake || die "build failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "Install failed"
	dodoc NEWS README* THANKS AUTHORS BUGS ChangeLog
	docinto examples
	dodoc "${FILESDIR}"/{dos2unix,unix2dos}
}
