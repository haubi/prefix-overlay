# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/e2fsprogs/e2fsprogs-1.41.3.ebuild,v 1.1 2008/10/18 16:44:15 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib

DESCRIPTION="Standard EXT2 and EXT3 filesystem utilities"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls elibc_FreeBSD"

RDEPEND="~sys-libs/${PN}-libs-${PV}
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.38-tests-locale.patch #99766
	epatch "${FILESDIR}"/${PN}-1.41.2-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40-fbsd.patch
	# blargh ... trick e2fsprogs into using e2fsprogs-libs
	rm -rf doc
	sed -i -r \
		-e 's:@LIBINTL@:@LTLIBINTL@:' \
		-e '/^LIB(BLKID|COM_ERR|SS|UUID)/s:[$][(]LIB[)]/lib([^@]*)@LIB_EXT@:-l\1:' \
		-e '/^DEPLIB(BLKID|COM_ERR|SS|UUID)/s:=.*:=:' \
		MCONFIG.in || die "muck libs" #122368
	sed -i -r \
		-e '/^LIB_SUBDIRS/s:lib/(blkid|et|ss|uuid)::g' \
		Makefile.in || die "remove subdirs"
	touch lib/ss/ss_err.h
}

src_compile() {
	# Keep the package from doing silly things
	addwrite /var/cache/fonts
	export LDCONFIG=:
	export CC=$(tc-getCC)
	export STRIP=:

	econf \
		--bindir="${EPREFIX}"/bin \
		--sbindir="${EPREFIX}"/sbin \
		--enable-elf-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !elibc_uclibc tls) \
		--without-included-gettext \
		$(use_enable nls) \
		$(use_enable userland_GNU fsck) \
		|| die
	if [[ ${CHOST} != *-uclibc ]] && grep -qs 'USE_INCLUDED_LIBINTL.*yes' config.{log,status} ; then
		eerror "INTL sanity check failed, aborting build."
		eerror "Please post your ${S}/config.log file as an"
		eerror "attachment to http://bugs.gentoo.org/show_bug.cgi?id=81096"
		die "Preventing included intl cruft from building"
	fi
	emake COMPILE_ET=compile_et MK_CMDS=mk_cmds || die

	# Build the FreeBSD helper
	if use elibc_FreeBSD ; then
		cp "${FILESDIR}"/fsck_ext2fs.c .
		emake fsck_ext2fs || die
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die
	emake DESTDIR="${D}" install-libs || die
	dodoc README RELEASE-NOTES

	# Move shared libraries to /lib/, install static libraries to /usr/lib/,
	# and install linker scripts to /usr/lib/.
	dodir /$(get_libdir)
	local lib slib
	for lib in "${ED}"/usr/$(get_libdir)/*.a ; do
		slib=${lib##*/}
		mv "${lib%.a}"$(get_libname)* "${ED}"/$(get_libdir)/ || die "moving lib ${slib}"
		gen_usr_ldscript ${slib%.a}$(get_libname)
	done

	# move 'useless' stuff to /usr/
	dosbin "${ED}"/sbin/mklost+found
	rm -f "${ED}"/sbin/mklost+found

	if use elibc_FreeBSD ; then
		# Install helpers for us
		into /
		dosbin "${S}"/fsck_ext2fs || die
		doman "${FILESDIR}"/fsck_ext2fs.8

		# these manpages are already provided by FreeBSD libc
		# and filefrag is linux only
		rm -f \
			"${ED}"/sbin/filefrag \
			"${ED}"/usr/share/man/man8/filefrag.8 \
			"${ED}"/bin/uuidgen \
			"${ED}"/usr/share/man/man3/{uuid,uuid_compare}.3 \
			"${ED}"/usr/share/man/man1/uuidgen.1 || die
	fi
}
