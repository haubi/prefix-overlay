# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.9.ebuild,v 1.1 2009/08/23 21:27:55 vapier Exp $

EAPI=2

inherit toolchain-funcs

DESCRIPTION="e2fsprogs libraries (common error and subsystem)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~m68k-mint"
IUSE="nls"

RDEPEND="elibc_glibc? ( !prefix? ( >=sys-libs/glibc-2.6 ) )
	!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41.8"
DEPEND="nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	sys-devel/bc"

export VARTEXFONTS=${T}/fonts #281390

src_prepare() {
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure

	#epatch "${FILESDIR}"/${PN}-1.41.1-darwin-makefile.patch
	if [[ ${CHOST} == *-mint* ]]; then
		sed -i -e 's/_SVID_SOURCE/_GNU_SOURCE/' lib/uuid/gen_uuid.c || die
	fi
}

src_configure() {
	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=--enable-bsd-shlibs  ;;
		*-mint*)   libtype=                     ;;
		*)         libtype=--enable-elf-shlibs  ;;
	esac

	# avoid a problem during parallel make, it bails because it creates the pic
	# directory too late
	mkdir ./lib/blkid/pic ./lib/et/pic ./lib/ss/pic ./lib/uuid/pic 

	# we use blkid/uuid from util-linux now
	ac_cv_lib_uuid_uuid_generate=yes \
	ac_cv_lib_blkid_blkid_get_cache=yes \
	ac_cv_path_LDCONFIG=: \
	econf \
		--disable-libblkid \
		--disable-libuuid \
		${libtype} \
		$(use_enable !elibc_uclibc tls) \
		$(use_enable nls)
}

src_install() {
	emake STRIP=: DESTDIR="${D}" install || die
	gen_usr_ldscript -a com_err ss
}
