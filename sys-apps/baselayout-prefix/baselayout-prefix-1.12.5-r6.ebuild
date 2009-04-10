# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="prefix"

RESTRICT="mirror"

inherit eutils toolchain-funcs multilib prefix

DESCRIPTION="Baselayout and init scripts (eventually)"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/${P/-prefix/}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="prefix-chaining"
DEPEND=">=sys-apps/portage-2.0.51"
RDEPEND=">=sys-libs/readline-5.0-r1
	>=app-shells/bash-3.1_p7
	>=sys-apps/coreutils-5.2.1"

PROVIDE="virtual/baselayout"

S=${WORKDIR}/${P/-prefix}

src_unpack() {
	unpack ${A}

	epatch "${FILESDIR}"/${P/-prefix/}-prefix.patch
	use prefix-chaining && epatch "${FILESDIR}"/${P/-prefix/}-prefix-chaining.patch
	cd "${S}"
	eprefixify \
		etc/env.d/00basic \
		etc/profile \
		sbin/env-update.sh \
		sbin/functions.sh \
		sbin/runscript.sh
	# add the host OS MANPATH
	echo 'MANPATH="/usr/share/man"' > etc/env.d/99basic || die "can't make file"
}

src_compile() {
	local libdir="lib"

	[[ ${SYMLINK_LIB} == "yes" ]] && libdir=$(get_abi_LIBDIR "${DEFAULT_ABI}")

# doesn't compile on Darwin
	#make -C "${S}"/src \
	#	CC="$(tc-getCC)" \
	#	LD="$(tc-getCC) ${LDFLAGS}" \
	#	CFLAGS="${CFLAGS}" \
	#	LIBDIR="${libdir}" || die
}

src_install() {
	local dir libdirs libdirs_env rcscripts_dir

	dodir /etc
	dodir /etc/env.d
	dodir /etc/init.d			# .keep file might mess up init.d stuff

	libdirs=$(get_all_libdirs)
	: ${libdirs:=lib}	# it isn't that we don't trust multilib.eclass...

	rcscripts_dir="/lib/rcscripts"

	for dir in ${libdirs}; do
		libdirs_env=${libdirs_env:+$libdirs_env:}/${dir}:/usr/${dir}:/usr/local/${dir}
		[[ ${dir} == "lib" && ${SYMLINK_LIB} == "yes" ]] && continue
		dodir /"${dir}"
		dodir /usr/"${dir}"
		dodir /usr/local/"${dir}"
	done

	# Ugly compatibility with stupid ebuilds and old profiles symlinks
	if [[ ${SYMLINK_LIB} == "yes" ]] ; then
		rm -r "${ED}"/{lib,usr/lib,usr/local/lib} &> /dev/null
		dosym $(get_abi_LIBDIR ${DEFAULT_ABI}) /lib
		dosym $(get_abi_LIBDIR ${DEFAULT_ABI}) /usr/lib
		dosym $(get_abi_LIBDIR ${DEFAULT_ABI}) /usr/local/lib
	fi

	# FHS compatibility symlinks stuff
	dosym /var/tmp /usr/tmp

	# rc-scripts version for testing of features that *should* be present
	echo "Gentoo Prefixed Base System version ${PV}" > ${ED}/etc/gentoo-release

	# get the basic stuff in there
	doenvd "${S}"/etc/env.d/* || die "doenvd"

	# copy the profile
	cp "${S}"/etc/profile "${ED}"/etc/profile

	# Setup files in /sbin
	#
	cd "${S}"/sbin
	into /
	# These moved from /etc/init.d/ to /sbin to help newb systems
	# from breaking
	dosbin runscript.sh functions.sh

	# Compat symlinks between /etc/init.d and /sbin
	# (some stuff have hardcoded paths)
	dosym ../../sbin/depscan.sh /etc/init.d/depscan.sh
	dosym ../../sbin/runscript.sh /etc/init.d/runscript.sh
	dosym ../../sbin/functions.sh /etc/init.d/functions.sh

	# We can only install new, fast awk versions of scripts
	# if 'build' or 'bootstrap' is not in USE.  This will
	# change if we have sys-apps/gawk-3.1.1-r1 or later in
	# the build image ...
#	if ! use build; then
		# This is for new depscan.sh and env-update.sh
		# written in awk
		cd "${S}"/sbin
		into /
		dosbin depscan.sh
		dosbin env-update.sh
		insinto ${rcscripts_dir}/awk
		doins "${S}"/src/awk/functions.awk
#	fi

	#
	# Install baselayout utilities
	#
	local libdir="lib"
	[[ ${SYMLINK_LIB} == "yes" ]] && libdir=$(get_abi_LIBDIR "${DEFAULT_ABI}")

# doesn't compile on Darwin
	#cd "${S}"/src
	#make DESTDIR="${D}" LIBDIR="${libdir}" install || die
}

pkg_postinst() {
	# This is also written in src_install (so it's in CONTENTS), but
	# write it here so that the new version is immediately in the file
	# (without waiting for the user to do etc-update)
	rm -f ${EROOT}/etc/._cfg????_gentoo-release
	echo "Gentoo Prefix Base System version ${PV}" > ${EROOT}/etc/gentoo-release

	echo
	einfo "Please be sure to update all pending '._cfg*' files in /etc,"
	einfo "else things might break!  You can use 'etc-update'"
	einfo "to accomplish this:"
	einfo
	einfo "  # etc-update"
	echo
}
