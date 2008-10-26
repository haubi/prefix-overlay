# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/attr/attr-2.4.41.ebuild,v 1.8 2008/10/26 03:34:49 vapier Exp $

EAPI="prefix"

inherit eutils autotools toolchain-funcs multilib flag-o-matic

MY_P="${PN}_${PV}-1"
DESCRIPTION="Extended attributes tools"
HOMEPAGE="http://oss.sgi.com/projects/xfs/"
SRC_URI="ftp://oss.sgi.com/projects/xfs/download/cmd_tars/${MY_P}.tar.gz
	ftp://xfs.org/mirror/SGI/cmd_tars/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
#KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )
	sys-devel/autoconf"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.4.39-gettext.patch
	epatch "${FILESDIR}"/${PN}-2.4.39-linguas.patch #205948
	epatch "${FILESDIR}"/${PN}-2.4.24-only-symlink-when-needed.patch
	epatch "${FILESDIR}"/${P}-no-static-paths.patch
	epatch "${FILESDIR}"/${P}-features_h.patch
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	# libtool will clobber install-sh which is really a custom file
	mv install-sh acl.install-sh || die
	AT_M4DIR="m4" eautoreconf
	mv acl.install-sh install-sh || die
	strip-linguas po

	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/__THROW//g' include/xattr.h
		sed -i -e '/^LTLDFLAGS/d' libattr/Makefile
		append-flags -fno-strict-aliasing
		append-ldflags -lintl
	fi
}

src_compile() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir) \
		--bindir="${EPREFIX}"/bin \
		|| die
	emake || die
}

src_install() {
	emake DIST_ROOT="${D}" install install-lib install-dev || die
	# the man-pages packages provides the man2 files
	rm -r "${ED}"/usr/share/man/man2
	prepalldocs

	# move shared libs to /
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/libattr*$(get_libname)* "${ED}"/$(get_libdir)/ || die
	gen_usr_ldscript libattr$(get_libname)
}
