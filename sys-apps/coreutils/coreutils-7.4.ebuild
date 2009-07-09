# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-7.4.ebuild,v 1.3 2009/07/06 22:33:58 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs

PATCH_VER="1"
DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="ftp://alpha.gnu.org/gnu/coreutils/${P}.tar.gz
	mirror://gnu/${PN}/${P}.tar.gz
	mirror://gentoo/${P}.tar.gz
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.lzma
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.lzma"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl caps gmp nls selinux static vanilla xattr"

RDEPEND="caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp )
	selinux? ( sys-libs/libselinux )
	xattr? ( sys-apps/attr )
	nls? ( >=sys-devel/gettext-0.15 )
	!<sys-apps/util-linux-2.13
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4
	!<sci-chemistry/ccp4-6.1.1
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if ! use vanilla ; then
		EPATCH_SUFFIX="patch" \
		PATCHDIR="${WORKDIR}/patch" \
		EPATCH_EXCLUDE="001_all_coreutils-gen-progress-bar.patch" \
		epatch
	fi

	epatch "${FILESDIR}"/${PN}-7.2-mint.patch
	epatch "${FILESDIR}"/${PN}-7.1-interix-fs.patch

	# Since we've patched many .c files, the make process will try to
	# re-build the manpages by running `./bin --help`.  When doing a
	# cross-compile, we can't do that since 'bin' isn't a native bin.
	# Also, it's not like we changed the usage on any of these things,
	# so let's just update the timestamps and skip the help2man step.
	set -- man/*.x
	tc-is-cross-compiler && touch ${@/%x/1}
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		append-flags "-Dgetgrgid=getgrgid_nomembers"
		append-flags "-Dgetgrent=getgrent_nomembers"
		append-flags "-Dgetgrnam=getgrnam_nomembers"
	fi

	use static && append-ldflags -static
	# kill/uptime - procps
	# groups/su   - shadow
	# hostname    - net-tools
	if [[ ${CHOST} == *-mint* ]]; then
		myconf="${myconf} --enable-install-program=arch,hostname,kill,uptime"
		myconf="${myconf} --enable-no-install-program=groups,su"
	else
		myconf="${myconf} --enable-install-program=arch"
		myconf="${myconf} --enable-no-install-program=groups,hostname,kill,su,uptime"
	fi
	econf \
		${myconf} \
		--enable-largefile \
		$(use_enable caps libcap) \
		$(use_enable nls) \
		$(use_enable acl) \
		$(use_enable xattr) \
		$(use_with gmp) \
		|| die "econf"
	emake || die "emake"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"

	# coreutils tests like to do `mount` and such with temp dirs
	# so make sure /etc/mtab is writable #265725
	# make sure /dev/loop* can be mounted #269758
	mkdir -p "${T}"/mount-wrappers
	mkwrap() {
		local w ww
		for w in "$@" ; do
			ww="${T}/mount-wrappers/${w}"
			cat <<-EOF > "${ww}"
				#!${EPREFIX}/bin/sh
				exec env SANDBOX_WRITE="\${SANDBOX_WRITE}:/etc/mtab:/dev/loop" $(type -P $w) "\$@"
			EOF
			chmod a+rx "${ww}"
		done
	}
	mkwrap mount umount

	addwrite /dev/full
	#export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	env PATH="${T}/mount-wrappers:${PATH}" \
	emake -j1 -k check || die "make check failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	insinto /etc
	newins src/dircolors.hin DIR_COLORS || die

	if [[ ${USERLAND} == "GNU" || ${EPREFIX%/} != "" ]] ; then
		cd "${ED}"/usr/bin
		dodir /bin
		# move critical binaries into /bin (required by FHS)
		local fhs="cat chgrp chmod chown cp date dd echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"

		# on interix "df" is not built, since there are no means of
		# getting a list of mounted filesystems.
		[[ ${CHOST} != *-interix* ]] && fhs="${fhs} df"

		[[ ${CHOST} == *-mint* ]] && fhs="${fhs} hostname"

		mv ${fhs} ../../bin/ || die "could not move fhs bins"
		# move critical binaries into /bin (common scripts)
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "could not move common bins"
		# create a symlink for uname in /usr/bin/ since autotools require it
		local x
		for x in ${com} uname ; do
			dosym /bin/${x} /usr/bin/${x} || die
		done
	else
		# For now, drop the man pages, collides with the ones of the system.
		rm -rf "${ED}"/usr/share/man
	fi

	# collision with libiconv
	rm -rf "${ED}"/usr/$(get_libdir)/charset.alias
}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells"

	# /bin/dircolors sometimes sticks around #224823
	if [ -e "${EROOT}/usr/bin/dircolors" ] && [ -e "${EROOT}/bin/dircolors" ] ; then
		if strings "${EROOT}/bin/dircolors" | grep -qs "GNU coreutils" ; then
			einfo "Deleting orphaned GNU /bin/dircolors for you"
			rm -f "${EROOT}/bin/dircolors"
		fi
	fi
}
