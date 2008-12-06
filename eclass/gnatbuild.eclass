# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gnatbuild.eclass,v 1.44 2008/12/05 08:36:00 george Exp $
#
# Author: George Shapovalov <george@gentoo.org>
# Belongs to: ada herd <ada@gentoo.org>
#
# Notes:
#  HOMEPAGE and LICENSE are set in appropriate ebuild, as
#  gnat is developed by FSF and AdaCore "in parallel"
#
# The following vars can be set in ebuild before inheriting this eclass. They
# will be respected:
#  SLOT
#  BOOT_SLOT - where old bootstrap is used as it works fine


inherit eutils versionator toolchain-funcs flag-o-matic multilib autotools \
	libtool fixheadtails gnuconfig pax-utils

EXPORT_FUNCTIONS pkg_setup pkg_postinst pkg_postrm src_unpack src_compile src_install

DESCRIPTION="Based on the ${ECLASS} eclass"

IUSE="nls"
# multilib is supported via profiles now, multilib usevar is deprecated

DEPEND=">=app-admin/eselect-gnat-1.3"
RDEPEND="app-admin/eselect-gnat"

# Note!
# It may not be safe to source this at top level. Only source inside local
# functions!
GnatCommon="/usr/share/gnat/lib/gnat-common.bash"

#---->> globals and SLOT <<----

# just a check, this location seems to vary too much, easier to track it in
# ebuild
#[ -z "${GNATSOURCE}" ] && die "please set GNATSOURCE in ebuild! (before inherit)"

# versioning
# because of gnatpro/gnatgpl we need to track both gcc and gnat versions

# these simply default to $PV
GNATMAJOR=$(get_version_component_range 1)
GNATMINOR=$(get_version_component_range 2)
GNATBRANCH=$(get_version_component_range 1-2)
GNATRELEASE=$(get_version_component_range 1-3)
# this one is for the gnat-gpl which is versioned by gcc backend and ACT version
# number added on top
ACT_Ver=$(get_version_component_range 4)

# GCCVER and SLOT logic
#
# I better define vars for package names, as there was discussion on proper
# naming and it may change
PN_GnatGCC="gnat-gcc"
PN_GnatGpl="gnat-gpl"

# ATTN! GCCVER stands for the provided backend gcc, not the one on the system
# so tc-* functions are of no use here. The present versioning scheme makes
# GCCVER basically a part of PV, but *this may change*!!
#
# GCCVER can be set in the ebuild. 
[[ -z ${GCCVER} ]] && GCCVER="${GNATRELEASE}"


# finally extract GCC version strings
GCCMAJOR=$(get_version_component_range 1 "${GCCVER}")
GCCMINOR=$(get_version_component_range 2 "${GCCVER}")
GCCBRANCH=$(get_version_component_range 1-2 "${GCCVER}")
GCCRELEASE=$(get_version_component_range 1-3 "${GCCVER}")

# SLOT logic, make it represent gcc backend, as this is what matters most
# There are some special cases, so we allow it to be defined in the ebuild
# ATTN!! If you set SLOT in the ebuild, don't forget to make sure that
# BOOT_SLOT is also set properly!
[[ -z ${SLOT} ]] && SLOT="${GCCBRANCH}"

# possible future crosscompilation support
export CTARGET=${CTARGET:-${CHOST}}

is_crosscompile() {
	[[ ${CHOST} != ${CTARGET} ]]
}

# Bootstrap CTARGET and SLOT logic. For now BOOT_TARGET=CHOST is "guaranteed" by
# profiles, so mostly watch out for the right SLOT used in the bootstrap.
# As above, with SLOT, it may need to be defined in the ebuild
BOOT_TARGET=${CTARGET}
[[ -z ${BOOT_SLOT} ]] && BOOT_SLOT=${SLOT}

# set our install locations
PREFIX=${GNATBUILD_PREFIX:-${EPREFIX}/usr} # not sure we need this hook, but may be..
LIBPATH=${PREFIX}/$(get_libdir)/${PN}/${CTARGET}/${SLOT}
LIBEXECPATH=${PREFIX}/libexec/${PN}/${CTARGET}/${SLOT}
INCLUDEPATH=${LIBPATH}/include
BINPATH=${PREFIX}/${CTARGET}/${PN}-bin/${SLOT}
DATAPATH=${PREFIX}/share/${PN}-data/${CTARGET}/${SLOT}
# ATTN! the one below should match the path defined in eselect-gnat module
CONFIG_PATH="/usr/share/gnat/eselect"
gnat_profile="${CTARGET}-${PN}-${SLOT}"
gnat_config_file="${CONFIG_PATH}/${gnat_profile}"


# ebuild globals
if [[ ${PN} == "${PN_GnatPro}" ]] && [[ ${GNATMAJOR} == "3" ]]; then
		DEPEND="x86? ( >=app-shells/tcsh-6.0 )"
fi
S="${WORKDIR}/gcc-${GCCVER}"

# bootstrap globals, common to src_unpack and src_compile
GNATBOOT="${WORKDIR}/usr"
GNATBUILD="${WORKDIR}/build"

# necessary for detecting lib locations and creating env.d entry
#XGCC="${GNATBUILD}/gcc/xgcc -B${GNATBUILD}/gcc"

#----<< globals and SLOT >>----

# set SRC_URI's in ebuilds for now

#----<< support checks >>----
# skipping this section - do not care about hardened/multilib for now

#---->> specs + env.d logic <<----
# TODO!!!
# set MANPATH, etc..
#----<< specs + env.d logic >>----


#---->> some helper functions <<----
is_multilib() {
	[[ ${GCCMAJOR} < 3 ]] && return 1
	case ${CTARGET} in
		mips64*|powerpc64*|s390x*|sparc64*|x86_64*)
			has_multilib_profile || use multilib ;;
		*)  false ;;
	esac
}

# adapted from toolchain,
# left only basic multilib functionality and cut off mips stuff

create_specs_file() {
	einfo "Creating a vanilla gcc specs file"
	"${WORKDIR}"/build/gcc/xgcc -dumpspecs > "${WORKDIR}"/build/vanilla.specs
}


# eselect stuff taken straight from toolchain.eclass and greatly simplified
add_profile_eselect_conf() {
	local gnat_config_file=$1
	local abi=$2
	local var

	echo >> "${ED}/${gnat_config_file}"
	if ! is_multilib ; then
		echo "  ctarget=${CTARGET}" >> "${ED}/${gnat_config_file}"
	else
		echo "[${abi}]" >> "${ED}/${gnat_config_file}"
		var="CTARGET_${abi}"
		if [[ -n ${!var} ]] ; then
			echo "  ctarget=${!var}" >> "${ED}/${gnat_config_file}"
		else
			var="CHOST_${abi}"
			if [[ -n ${!var} ]] ; then
				echo "  ctarget=${!var}" >> "${ED}/${gnat_config_file}"
			else
				echo "  ctarget=${CTARGET}" >> "${ED}/${gnat_config_file}"
			fi
		fi
	fi

	var="CFLAGS_${abi}"
	if [[ -n ${!var} ]] ; then
		echo "  cflags=${!var}" >> "${ED}/${gnat_config_file}"
	fi
}


create_eselect_conf() {
	local abi

	dodir ${CONFIG_PATH}

	echo "[global]" > "${ED}/${gnat_config_file}"
	echo "  version=${CTARGET}-${SLOT}" >> "${ED}/${gnat_config_file}"
	echo "  binpath=${BINPATH}" >> "${ED}/${gnat_config_file}"
	echo "  libexecpath=${LIBEXECPATH}" >> "${ED}/${gnat_config_file}"
	echo "  ldpath=${LIBPATH}" >> "${ED}/${gnat_config_file}"
	echo "  manpath=${DATAPATH}/man" >> "${ED}/${gnat_config_file}"
	echo "  infopath=${DATAPATH}/info" >> "${ED}/${gnat_config_file}"
	echo "  bin_prefix=${CTARGET}" >> "${ED}/${gnat_config_file}"

	for abi in $(get_all_abis) ; do
		add_profile_eselect_conf "${ED}/${gnat_config_file}" "${abi}"
	done
}



should_we_eselect_gnat() {
	# we only want to switch compilers if installing to / or /tmp/stage1root
	[[ ${EROOT} == "/" ]] || return 1

	# if the current config is invalid, we definitely want a new one
	# Note: due to bash quirkiness, the following must not be 1 line
	local curr_config
	curr_config=$(eselect --no-color gnat show | grep ${CTARGET} | awk '{ print $1 }') || return 0
	[[ -z ${curr_config} ]] && return 0

	# The logic is basically "try to keep the same profile if possible"

	if [[ ${curr_config} == ${CTARGET}-${PN}-${SLOT} ]] ; then
		return 0
	else
		elog "The current gcc config appears valid, so it will not be"
		elog "automatically switched for you.  If you would like to"
		elog "switch to the newly installed gcc version, do the"
		elog "following:"
		echo
		elog "eselect gnat set <profile>"
		echo
		ebeep
		return 1
	fi
}

# active compiler selection, called from pkg_postinst
do_gnat_config() {
	eselect gnat set ${CTARGET}-${PN}-${SLOT} &> /dev/null

	elog "The following gnat profile has been activated:"
	elog "${CTARGET}-${PN}-${SLOT}"
	elog ""
	elog "The compiler has been installed as gnatgcc, and the coverage testing"
	elog "tool as gnatgcov."
	elog ""
	elog "Ada handling in Gentoo allows you to have multiple gnat variants"
	elog "installed in parallel and automatically manage Ada libs."
	elog "Please take a look at the Ada project page for some documentation:"
	elog "http://www.gentoo.org/proj/en/prog_lang/ada/index.xml"
}


# Taken straight from the toolchain.eclass. Only removed the "obsolete hunk"
#
# The purpose of this DISGUSTING gcc multilib hack is to allow 64bit libs
# to live in lib instead of lib64 where they belong, with 32bit libraries
# in lib32. This hack has been around since the beginning of the amd64 port,
# and we're only now starting to fix everything that's broken. Eventually
# this should go away.
#
# Travis Tilley <lv@gentoo.org> (03 Sep 2004)
#
disgusting_gcc_multilib_HACK() {
	local config
	local libdirs
	if has_multilib_profile ; then
		case $(tc-arch) in
			amd64)
				config="i386/t-linux64"
				libdirs="../$(get_abi_LIBDIR amd64) ../$(get_abi_LIBDIR x86)" \
			;;
			ppc64)
				config="rs6000/t-linux64"
				libdirs="../$(get_abi_LIBDIR ppc64) ../$(get_abi_LIBDIR ppc)" \
			;;
		esac
	else
		die "Your profile is no longer supported by portage."
	fi

	einfo "updating multilib directories to be: ${libdirs}"
	sed -i -e "s:^MULTILIB_OSDIRNAMES.*:MULTILIB_OSDIRNAMES = ${libdirs}:" "${S}"/gcc/config/${config}
}


#---->> pkg_* <<----
gnatbuild_pkg_setup() {
	debug-print-function ${FUNCNAME} $@

	# Setup variables which would normally be in the profile
	if is_crosscompile ; then
		multilib_env ${CTARGET}
	fi

	# we dont want to use the installed compiler's specs to build gnat!
	unset GCC_SPECS
}

gnatbuild_pkg_postinst() {
	if should_we_eselect_gnat; then
		do_gnat_config
	else
		eselect gnat update
	fi

	# if primary compiler list is empty, add this profile to the list, so
	# that users are not left without active compilers (making sure that
	# libs are getting built for at least one)
	elog
	. ${GnatCommon} || die "failed to source common code"
	if [[ ! -f ${PRIMELIST} ]] || [[ ! -s ${PRIMELIST} ]]; then
		echo "${gnat_profile}" > ${PRIMELIST}
		elog "The list of primary compilers was empty and got assigned ${gnat_profile}."
	fi
	elog "Please edit ${PRIMELIST} and list there gnat profiles intended"
	elog "for common use."
}


gnatbuild_pkg_postrm() {
	# "eselect gnat update" now removes the env.d file if the corresponding 
	# gnat profile was unmerged
	eselect gnat update
	elog "If you just unmerged the last gnat in this SLOT, your active gnat"
	elog "profile got unset. Please check what eselect gnat show tells you"
	elog "and set the desired profile"
}
#---->> pkg_* <<----

#---->> src_* <<----

# common unpack stuff
gnatbuild_src_unpack() {
	debug-print-function ${FUNCNAME} $@
	[ -z "$1" ] &&  gnatbuild_src_unpack all

	while [ "$1" ]; do
	case $1 in
		base_unpack)
			unpack ${A}
			pax-mark pmsE $(find ${GNATBOOT} -name gnat1)

			cd "${S}"
			# patching gcc sources, following the toolchain
			if [[ -d "${FILESDIR}"/${SLOT} ]] ; then
				EPATCH_MULTI_MSG="Applying Gentoo patches ..." \
				epatch "${FILESDIR}"/${SLOT}/*.patch
			fi
			# Replacing obsolete head/tail with POSIX compliant ones
			ht_fix_file */configure

			if ! is_crosscompile && is_multilib && \
				[[ ( $(tc-arch) == "amd64" || $(tc-arch) == "ppc64" ) && -z ${SKIP_MULTILIB_HACK} ]] ; then
					disgusting_gcc_multilib_HACK || die "multilib hack failed"
			fi

			# Fixup libtool to correctly generate .la files with portage
			cd "${S}"
			elibtoolize --portage --shallow --no-uclibc

			gnuconfig_update
			# update configure files
			einfo "Fixing misc issues in configure files"
			for f in $(grep -l 'autoconf version 2.13' $(find "${S}" -name configure)) ; do
				ebegin "  Updating ${f}"
				patch "${f}" "${FILESDIR}"/gcc-configure-LANG.patch >& "${T}"/configure-patch.log \
					|| eerror "Please file a bug about this"
				eend $?
			done

			# regenerate some configures tp fix ACT's omissions
			pushd "${S}"/gnattools &> /dev/null
				eautoconf
			popd &> /dev/null
		;;

		common_prep)
			# Prepare the gcc source directory
			cd "${S}/gcc"
			touch cstamp-h.in
			touch ada/[es]info.h
			touch ada/nmake.ad[bs]
			# set the compiler name to gnatgcc
			for i in `find ada/ -name '*.ad[sb]'`; do \
				sed -i -e "s/\"gcc\"/\"gnatgcc\"/g" ${i}; \
			done
			# add -fPIC flag to shared libs for 3.4* backend
			if [ "3.4" == "${GCCBRANCH}" ] ; then
				cd ada
				epatch "${FILESDIR}"/gnat-Make-lang.in.patch
			fi

			mkdir -p "${GNATBUILD}"
		;;

		all)
			gnatbuild_src_unpack base_unpack common_prep
		;;
	esac
	shift
	done
}

# it would be nice to split configure and make steps
# but both need to operate inside specially tuned evironment
# so just do sections for now (as in eclass section of handbook)
# sections are: configure, make-tools, bootstrap,
#  gnatlib_and_tools, gnatlib-shared
gnatbuild_src_compile() {
	debug-print-function ${FUNCNAME} $@
	if [[ -z "$1" ]]; then
		gnatbuild_src_compile all
		return $?
	fi

	if [[ "all" == "$1" ]]
	then # specialcasing "all" to avoid scanning sources unnecessarily
		gnatbuild_src_compile configure make-tools \
			bootstrap gnatlib_and_tools gnatlib-shared

	else
		# Set some paths to our bootstrap compiler.
		export PATH="${GNATBOOT}/bin:${PATH}"
		# !ATTN! the bootstrap compilers have a very simplystic structure,
		# so many paths are not identical to the installed ones.
		# Plus it was simplified even more in new releases.
		if [[ ${BOOT_SLOT} > 4.1 ]] ; then
			GNATLIB="${GNATBOOT}/lib"
		else
			GNATLIB="${GNATBOOT}/lib/gnatgcc/${BOOT_TARGET}/${BOOT_SLOT}"
		fi

		export CC="${GNATBOOT}/bin/gnatgcc"
		export INCLUDE_DIR="${GNATLIB}/include"
		export LIB_DIR="${GNATLIB}"
		export LDFLAGS="-L${GNATLIB}"

		# additional vars from gnuada and elsewhere
		export LD_RUN_PATH="${LIBPATH}"
		export LIBRARY_PATH="${GNATLIB}"
		export LD_LIBRARY_PATH="${GNATLIB}"
#		export COMPILER_PATH="${GNATBOOT}/bin/"

		export ADA_OBJECTS_PATH="${GNATLIB}/adalib"
		export ADA_INCLUDE_PATH="${GNATLIB}/adainclude"

#		einfo "CC=${CC},
#			ADA_INCLUDE_PATH=${ADA_INCLUDE_PATH},
#			LDFLAGS=${LDFLAGS},
#			PATH=${PATH}"

		while [ "$1" ]; do
		case $1 in
			configure)
				debug-print-section configure
				# Configure gcc
				local confgcc

				# some cross-compile logic from toolchain
				confgcc="${confgcc} --host=${CHOST}"
				if is_crosscompile || tc-is-cross-compiler ; then
					confgcc="${confgcc} --target=${CTARGET}"
				fi
				[[ -n ${CBUILD} ]] && confgcc="${confgcc} --build=${CBUILD}"

				# Native Language Support
				if use nls ; then
					confgcc="${confgcc} --enable-nls --without-included-gettext"
				else
					confgcc="${confgcc} --disable-nls"
				fi

				# reasonably sane globals (from toolchain)
				confgcc="${confgcc} \
					--with-system-zlib \
					--disable-checking \
					--disable-werror \
					--disable-libunwind-exceptions"

				# ACT's gnat-gpl does not like libada for whatever reason..
				if [[ ${PN} == ${PN_GnatGpl} ]]; then
					einfo "ACT's gnat-gpl does not like libada, disabling"
					confgcc="${confgcc} --disable-libada"
				else
					confgcc="${confgcc} --enable-libada"
				fi
#				einfo "confgcc=${confgcc}"

				cd "${GNATBUILD}"
				CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" "${S}"/configure \
					--prefix=${EPREFIX} \
					--bindir=${BINPATH} \
					--includedir=${INCLUDEPATH} \
					--libdir="${LIBPATH}" \
					--libexecdir="${LIBEXECPATH}" \
					--datadir=${DATAPATH} \
					--mandir=${DATAPATH}/man \
					--infodir=${DATAPATH}/info \
					--program-prefix=gnat \
					--enable-languages="c,ada" \
					--with-gcc \
					--enable-threads=posix \
					--enable-shared \
					--with-system-zlib \
					${confgcc} || die "configure failed"
			;;

			make-tools)
				debug-print-section make-tools
				# Compile helper tools
				cd "${GNATBOOT}"
				cp "${S}"/gcc/ada/xtreeprs.adb .
				cp "${S}"/gcc/ada/xsinfo.adb   .
				cp "${S}"/gcc/ada/xeinfo.adb   .
				cp "${S}"/gcc/ada/xnmake.adb   .
				gnatmake xtreeprs && \
				gnatmake xsinfo   && \
				gnatmake xeinfo   && \
				gnatmake xnmake   || die "building helper tools"
			;;

			bootstrap)
				debug-print-section bootstrap
				# and, finally, the build itself
				cd "${GNATBUILD}"
				emake bootstrap || die "bootstrap failed"
			;;

			gnatlib_and_tools)
				debug-print-section gnatlib_and_tools
				einfo "building gnatlib_and_tools"
				cd "${GNATBUILD}"
				emake -j1 -C gcc gnatlib_and_tools || \
					die "gnatlib_and_tools failed"
			;;

			gnatlib-shared)
				debug-print-section gnatlib-shared
				einfo "building shared lib"
				cd "${GNATBUILD}"
				rm -f gcc/ada/rts/*.{o,ali} || die
				#otherwise make tries to reuse already compiled (without -fPIC) objs..
				emake -j1 -C gcc gnatlib-shared LIBRARY_VERSION="${GCCBRANCH}" || \
					die "gnatlib-shared failed"
			;;

		esac
		shift
		done # while
	fi   # "all" == "$1"
}
# -- end gnatbuild_src_compile


gnatbuild_src_install() {
	debug-print-function ${FUNCNAME} $@

	if [[ -z "$1" ]] ; then
		gnatbuild_src_install all
		return $?
	fi

	while [ "$1" ]; do
	case $1 in
	install) # runs provided make install
		debug-print-section install

		# Looks like we need an access to the bootstrap compiler here too
		# as gnat apparently wants to compile something during the installation
		# The spotted obuser was xgnatugn, used to process gnat_ugn_urw.texi,
		# during preparison of the docs.
		export PATH="${GNATBOOT}/bin:${PATH}"
		GNATLIB="${GNATBOOT}/lib/gnatgcc/${BOOT_TARGET}/${BOOT_SLOT}"

		export CC="${GNATBOOT}/bin/gnatgcc"
		export INCLUDE_DIR="${GNATLIB}/include"
		export LIB_DIR="${GNATLIB}"
		export LDFLAGS="-L${GNATLIB}"
		export ADA_OBJECTS_PATH="${GNATLIB}/adalib"
		export ADA_INCLUDE_PATH="${GNATLIB}/adainclude"

		# Do not allow symlinks in /usr/lib/gcc/${CHOST}/${MY_PV}/include as
		# this can break the build.
		for x in "${GNATBUILD}"/gcc/include/* ; do
			if [ -L ${x} ] ; then
				rm -f ${x}
			fi
		done
		# Remove generated headers, as they can cause things to break
		# (ncurses, openssl, etc). (from toolchain.eclass)
		for x in $(find "${WORKDIR}"/build/gcc/include/ -name '*.h') ; do
			grep -q 'It has been auto-edited by fixincludes from' "${x}" \
				&& rm -f "${x}"
		done


		cd "${GNATBUILD}"
		make DESTDIR="${D}" install || die

		#make a convenience info link
		dosym ${DATAPATH}/info/gnat_ugn_unw.info ${DATAPATH}/info/gnat.info
		;;

	move_libs)
		debug-print-section move_libs

		# first we need to remove some stuff to make moving easier
		rm -rf "${ED}${LIBPATH}"/{32,include,libiberty.a}
		# gcc insists on installing libs in its own place
		mv "${ED}${LIBPATH}/gcc/${CTARGET}/${GCCRELEASE}"/* "${ED}${LIBPATH}"
		mv "${ED}${LIBEXECPATH}/gcc/${CTARGET}/${GCCRELEASE}"/* "${ED}${LIBEXECPATH}"

		# libgcc_s  and, with gcc>=4.0, other libs get installed in multilib specific locations by gcc
		# we pull everything together to simplify working environment
		if has_multilib_profile ; then
			case $(tc-arch) in
				amd64)
					mv "${ED}${LIBPATH}"/../$(get_abi_LIBDIR amd64)/* "${ED}${LIBPATH}"
					mv "${ED}${LIBPATH}"/../$(get_abi_LIBDIR x86)/* "${ED}${LIBPATH}"/32
				;;
				ppc64)
					# not supported yet, will have to be adjusted when we
					# actually build gnat for that arch
				;;
			esac
		fi

		# force gnatgcc to use its own specs - versions prior to 3.4.6 read specs
		# from system gcc location. Do the simple wrapper trick for now
		# !ATTN! change this if eselect-gnat starts to follow eselect-compiler
		if [[ ${GCCVER} < 3.4.6 ]] ; then
			# gcc 4.1 uses builtin specs. What about 4.0?
			cd "${ED}${BINPATH}"
			mv gnatgcc gnatgcc_2wrap
			cat > gnatgcc << EOF
#! /bin/bash
# wrapper to cause gnatgcc read appropriate specs and search for the right .h
# files (in case no matching gcc is installed)
BINDIR=\$(dirname \$0)
# The paths in the next line have to be absolute, as gnatgcc may be called from
# any location
\${BINDIR}/gnatgcc_2wrap -specs="${LIBPATH}/specs" -I"${LIBPATH}/include" \$@
EOF
			chmod a+x gnatgcc
		fi

		# earlier gnat's generate some Makefile's at generic location, need to
		# move to avoid collisions
		[ -f "${ED}${PREFIX}"/share/gnat/Makefile.generic ] &&
			mv "${ED}${PREFIX}"/share/gnat/Makefile.* "${ED}${DATAPATH}"

		# use gid of 0 because some stupid ports don't have
		# the group 'root' set to gid 0 (toolchain.eclass)
		chown -R root:0 "${ED}${LIBPATH}"
		;;

	cleanup)
		debug-print-section cleanup

		rm -rf "${ED}${LIBPATH}"/{gcc,install-tools,../lib{32,64}}
		rm -rf "${ED}${LIBEXECPATH}"/{gcc,install-tools}

		# this one is installed by gcc and is a duplicate even here anyway
		rm -f "${ED}${BINPATH}/${CTARGET}-gcc-${GCCRELEASE}"

		# remove duplicate docs
		cd "${ED}${DATAPATH}"
		has noinfo ${FEATURES} \
			&& rm -rf info \
			|| rm -f info/{dir,gcc,cpp}*
		has noman  ${FEATURES} \
			&& rm -rf man \
			|| rm -rf man/man7/
		;;

	prep_env)
		# instead of putting junk under /etc/env.d/gnat we recreate env files as
		# needed with eselect
		create_eselect_conf
		;;

	all)
		gnatbuild_src_install install move_libs cleanup prep_env
		;;
	esac
	shift
	done # while
}
# -- end gnatbuild_src_install
