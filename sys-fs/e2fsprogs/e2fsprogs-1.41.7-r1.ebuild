# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.41.7-r1.ebuild,v 1.2 2009/07/05 17:36:38 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Standard EXT2/EXT3/EXT4 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint"
IUSE="nls elibc_FreeBSD"

RDEPEND="~sys-libs/${PN}-libs-${PV}
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig
	sys-apps/texinfo"

pkg_setup() {
	if [[ ! -e ${EROOT}/etc/mtab ]] ; then
		# add some crap to deal with missing /etc/mtab #217719
		ewarn "No /etc/mtab file, creating one temporarily"
		echo "${PN} crap for src_test" > "${EROOT}"/etc/mtab
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch #99766
	epatch "${FILESDIR}"/${PN}-1.41.5-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40-fbsd.patch
	epatch "${FILESDIR}"/0001-resize2fs-Fix-error-message-so-the-mountpoint-is-pri.patch #276352
	epatch "${FILESDIR}"/${PN}-1.41.1-darwin-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.41.4-darwin-no-mntent.patch
	if [[ ${CHOST} == *-mint* ]] ; then
		epatch "${FILESDIR}"/${PN}-1.41-mint.patch
		epatch "${FILESDIR}"/${PN}-1.41.7-mint-blkid.patch
	fi
	# blargh ... trick e2fsprogs into using e2fsprogs-libs
	rm -rf doc
	sed -i -r \
		-e 's:@LIBINTL@:@LTLIBINTL@:' \
		-e '/^LIB(COM_ERR|SS)/s:[$][(]LIB[)]/lib([^@]*)@LIB_EXT@:-l\1:' \
		-e '/^DEPLIB(COM_ERR|SS)/s:=.*:=:' \
		MCONFIG.in || die "muck libs" #122368
	sed -i -r \
		-e '/^LIB_SUBDIRS/s:lib/(et|ss)::g' \
		Makefile.in || die "remove subdirs"
	# stupid configure script clobbers CC for us
	sed -i \
		-e '/if test -z "$CC" ; then CC=cc; fi/d' \
		configure || die "touching configure"

	# we want to build the blkid/findfs binaries, but not the libs
	sed -i \
		-e '/BLKID_CMT=/s:BLKID_CMT:LIBBLKID_CMT:g' \
		-e '/LIBUUID=`$PKG_CONFIG/s/--libs /--libs-only-l /' \
		configure || die "touching configure for blkid"
	sed -i \
		-e '/BLKID_LIB_SUBDIR/s:@BLKID_CMT@:@LIBBLKID_CMT@:g' \
		Makefile.in || die "remove blkid subdir better"
	append-cppflags -DCONFIG_BUILD_FINDFS #275923

	# Avoid rebuild
	touch lib/ss/ss_err.h
}

src_compile() {
	# Keep the package from doing silly things #261411
	export VARTEXFONTS=${T}/fonts

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=--enable-bsd-shlibs  ;;
		*-mint*)   libtype=                     ;;
		*)         libtype=--enable-elf-shlibs  ;;
	esac

	# On MacOSX 10.4 using the assembly built-in bitoperation functions causes
	# segmentation faults. Though this is likely fixable we can quickly make it
	# at least work by using the C functions.
	if [[ ${CHOST} == i?86-apple-darwin* ]]; then
		append-flags -D_EXT2_USE_C_VERSIONS_
	fi

	ac_cv_path_LDCONFIG=: \
	econf \
		--with-root-prefix="${EPREFIX}"/ \
		${libtype} \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !elibc_uclibc tls) \
		--without-included-gettext \
		$(use_enable nls) \
		$(use_enable userland_GNU fsck) \
		--disable-libblkid \
		--disable-libuuid \
		|| die
	if [[ ${CHOST} != *-uclibc ]] && grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to http://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
	# MKDIR pic is done too late: -j1
	emake -j1 COMPILE_ET=compile_et MK_CMDS=mk_cmds || die

	# Build the FreeBSD helper
	if use elibc_FreeBSD ; then
		cp "${FILESDIR}"/fsck_ext2fs.c .
		emake fsck_ext2fs || die
	fi
}

pkg_preinst() {
	if [[ -r ${EROOT}/etc/mtab ]] ; then
		if [[ $(<"${EROOT}"/etc/mtab) == "${PN} crap for src_test" ]] ; then
			rm -f "${EROOT}"/etc/mtab
		fi
	fi
}

src_install() {
	# need to set root_libdir= manually as any --libdir options in the
	# econf above (i.e. multilib) will screw up the default #276465
	emake \
		STRIP=: \
		root_libdir="${EPREFIX}/usr/$(get_libdir)" \
		DESTDIR="${D}" \
		install install-libs || die
	dodoc README RELEASE-NOTES

	# Move shared libraries to /lib/, install static libraries to
	# /usr/lib/, 	 
	# and install linker scripts to /usr/lib/. 	 
	set -- "${ED}"/usr/$(get_libdir)/*.a 	 
	set -- ${@/*\/lib} 	 
	gen_usr_ldscript -a "${@/.a}" 	 

	if use elibc_FreeBSD ; then
		# Install helpers for us
		into /
		dosbin "${S}"/fsck_ext2fs || die
		doman "${FILESDIR}"/fsck_ext2fs.8

		# these manpages are already provided by FreeBSD libc
		# and filefrag is linux only
		rm -f \
			"${ED}"/usr/sbin/filefrag \
			"${ED}"/usr/share/man/man8/filefrag.8 \
			"${ED}"/usr/bin/uuidgen \
			"${ED}"/usr/share/man/man3/{uuid,uuid_compare}.3 \
			"${ED}"/usr/share/man/man1/uuidgen.1 || die
	fi
}
