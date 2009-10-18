# Copyright 2007-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/qt4-build.eclass,v 1.48 2009/10/16 15:02:15 wired Exp $

# @ECLASS: qt4-build.eclass
# @MAINTAINER:
# Ben de Groot <yngwin@gentoo.org>,
# Markos Chandras <hwoarang@gentoo.org>,
# Caleb Tennis <caleb@gentoo.org>
# Alex Alexander <wired@gentoo.org>
# @BLURB: Eclass for Qt4 split ebuilds.
# @DESCRIPTION:
# This eclass contains various functions that are used when building Qt4

inherit base eutils multilib toolchain-funcs flag-o-matic versionator

IUSE="${IUSE} debug pch aqua"
RDEPEND="
	!<x11-libs/qt-assistant-${PV}
	!>x11-libs/qt-assistant-${PV}-r9999
	!<x11-libs/qt-core-${PV}
	!>x11-libs/qt-core-${PV}-r9999
	!<x11-libs/qt-dbus-${PV}
	!>x11-libs/qt-dbus-${PV}-r9999
	!<x11-libs/qt-demo-${PV}
	!>x11-libs/qt-demo-${PV}-r9999
	!<x11-libs/qt-gui-${PV}
	!>x11-libs/qt-gui-${PV}-r9999
	!<x11-libs/qt-opengl-${PV}
	!>x11-libs/qt-opengl-${PV}-r9999
	!<x11-libs/qt-phonon-${PV}
	!>x11-libs/qt-phonon-${PV}-r9999
	!<x11-libs/qt-qt3support-${PV}
	!>x11-libs/qt-qt3support-${PV}-r9999
	!<x11-libs/qt-script-${PV}
	!>x11-libs/qt-script-${PV}-r9999
	!<x11-libs/qt-sql-${PV}
	!>x11-libs/qt-sql-${PV}-r9999
	!<x11-libs/qt-svg-${PV}
	!>x11-libs/qt-svg-${PV}-r9999
	!<x11-libs/qt-test-${PV}
	!>x11-libs/qt-test-${PV}-r9999
	!<x11-libs/qt-webkit-${PV}
	!>x11-libs/qt-webkit-${PV}-r9999
	!<x11-libs/qt-xmlpatterns-${PV}
	!>x11-libs/qt-xmlpatterns-${PV}-r9999
"
case "${PV}" in
	4.?.?_rc* | 4.?.?_beta* )
		SRCTYPE="${SRCTYPE:-opensource-src}"
		MY_PV="${PV/_/-}"
		;;
	*)
		SRCTYPE="${SRCTYPE:-opensource-src}"
		MY_PV="${PV}"
		;;
esac

if version_is_at_least 4.5.99999999 ${PV} ; then
	MY_P="qt-everywhere-${SRCTYPE}-${MY_PV}"
else
	use aqua \
		&& MY_GE=mac \
		|| MY_GE=x11
	MY_P="qt-${MY_GE}-${SRCTYPE}-${MY_PV}"
fi
S=${WORKDIR}/${MY_P}

HOMEPAGE="http://qt.nokia.com/"
if version_is_at_least 4.5.99999999 ${PV} ; then
	SRC_URI="http://get.qt.nokia.com/qt/source/${MY_P}.tar.gz"
elif version_is_at_least 4.5.3 ${PV} ; then
	SRC_URI="aqua? ( http://get.qt.nokia.com/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.gz )
		!aqua? ( http://get.qt.nokia.com/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.gz )"
else
	SRC_URI="aqua? ( http://get.qt.nokia.com/qt/source/qt-mac-${SRCTYPE}-${MY_PV}.tar.bz2 )
		!aqua? ( http://get.qt.nokia.com/qt/source/qt-x11-${SRCTYPE}-${MY_PV}.tar.bz2 )"
fi

case "${PV}" in
	4.4.?)
		SRC_URI="${SRC_URI}
		         !aqua? ( mirror://gentoo/qt-x11-${SRCTYPE}-${MY_PV}-headers.tar.bz2 )"
		;;
	*)     ;;
esac

if version_is_at_least 4.5 ${PV} ; then
	LICENSE="|| ( LGPL-2.1 GPL-3 )"
fi

# @FUNCTION: qt4-build_pkg_setup
# @DESCRIPTION:
# Sets up installation directories, PLATFORM, PATH, and LD_LIBRARY_PATH
qt4-build_pkg_setup() {
	# EAPI=2 ebuilds set use-deps, others need this:
	if [[ $EAPI != 2 ]]; then
		# Make sure debug setting corresponds with qt-core (bug 258512)
		if [[ $PN != "qt-core" ]]; then
			use debug && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
				~x11-libs/qt-core-${PV} debug"
		fi

		# Check USE requirements
		qt4-build_check_use
	fi

	PATH="${S}/bin:${PATH}"
	if [[ ${CHOST} != *-darwin* ]]; then
		LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"
	else
		DYLD_LIBRARY_PATH="${S}/lib:${DYLD_LIBRARY_PATH}"
		# on mac we *need* src/gui/kernel/qapplication_mac.cpp for platfrom
		# detection since the x11-headers package b0rkens the header
		# installation, we have to extract src/ and includes/ completely on mac
		# tools is needed for qt-demo and some others
		QT4_EXTRACT_DIRECTORIES="
			${QT4_EXTRACT_DIRECTORIES}
			src
			include
		"
		
		if [[ ${PN} == qt-demo || ${PN} == qt-qt3support || ${PN} == qt-webkit ]]; then
			QT4_EXTRACT_DIRECTORIES="
				${QT4_EXTRACT_DIRECTORIES}
				tools
			"
		fi
	fi

	if ! version_is_at_least 4.1 $(gcc-version) ; then
		ewarn "Using a GCC version lower than 4.1 is not supported!"
		echo
		ebeep 3
	fi
}

# @ECLASS-VARIABLE: QT4_TARGET_DIRECTORIES
# @DESCRIPTION:
# Arguments for build_target_directories. Takes the directories, in which the
# code should be compiled. This is a space-separated list

# @ECLASS-VARIABLE: QT4_EXTRACT_DIRECTORIES
# @DESCRIPTION:
# Space separated list including the directories that will be extracted from Qt
# tarball

# @FUNCTION: qt4-build_src_unpack
# @DESCRIPTION:
# Unpacks the sources
qt4-build_src_unpack() {
	setqtenv
	local target targets licenses tar_pkg tar_args
	if version_is_at_least 4.5 ${PV} ; then
		licenses="LICENSE.GPL3 LICENSE.LGPL"
	else
		licenses="LICENSE.GPL2 LICENSE.GPL3"
	fi
	for target in configure ${licenses} projects.pro \
		src/{qbase,qt_targets,qt_install}.pri bin config.tests mkspecs qmake \
		${QT4_EXTRACT_DIRECTORIES}; do
			targets="${targets} ${MY_P}/${target}"
	done

	tar_pkg=${MY_P}.tar.bz2
	tar_args="xjpf"
	if version_is_at_least 4.5.3 ${PV} ; then
		tar_pkg=${tar_pkg/bz2/gz}
		tar_args="xzpf"
	fi

	echo tar ${tar_args} "${DISTDIR}"/${tar_pkg} ${targets}
	tar ${tar_args} "${DISTDIR}"/${tar_pkg} ${targets}

	if [[ ${CHOST} != *-darwin* ]]; then
		case "${PV}" in
			4.4.?)
				echo tar xjpf "${DISTDIR}"/qt-x11-${SRCTYPE}-${MY_PV}-headers.tar.bz2
				tar xjpf "${DISTDIR}"/qt-x11-${SRCTYPE}-${MY_PV}-headers.tar.bz2
				;;
		esac
	fi

	# Be backwards compatible for now
	if [[ $EAPI != 2 ]]; then
		qt4-build_src_prepare
	fi
}

# @ECLASS-VARIABLE: PATCHES
# @DESCRIPTION:
# In case you have patches to apply, specify them in PATCHES variable. Make sure
# to specify the full path. This variable is necessary for src_prepare phase.
# example:
# PATCHES="${FILESDIR}"/mypatch.patch
#   ${FILESDIR}"/mypatch2.patch"
#

# @FUNCTION: qt4-build_src_prepare
# @DESCRIPTION:
# Prepare the sources before the configure phase. Strip CFLAGS if necessary, and fix
# source files in order to respect CFLAGS/CXXFLAGS/LDFLAGS specified on /etc/make.conf.
qt4-build_src_prepare() {
	setqtenv
	cd "${S}"

	if use aqua; then
		# provide a proper macx-g++-64
		use x64-macos && ln -s macx-g++ mkspecs/$(qt_mkspecs_dir)

		sed -e '/^CONFIG/s:app_bundle::' \
			-e '/^CONFIG/s:plugin_no_soname:plugin_with_soname absolute_library_soname:' \
			-i "${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf || die "sed failed"
	fi

	if [[ ${PN} != qt-core ]]; then
		skip_qmake_build_patch
		skip_project_generation_patch
		symlink_binaries_to_buildtree
	fi

	if [[ ${CHOST} == *86*-apple-darwin* ]] ; then
		# qmake bus errors with -O2 but -O3 works
		replace-flags -O2 -O3
	fi

	# Bug 178652
	if [[ "$(gcc-major-version)" == "3" ]] && use amd64; then
		ewarn "Appending -fno-gcse to CFLAGS/CXXFLAGS"
		append-flags -fno-gcse
	fi

	# Unsupported old gcc versions - hardened needs this :(
	if [[ $(gcc-major-version) -lt "4" ]] ; then
		ewarn "Appending -fno-stack-protector to CXXFLAGS"
		append-cxxflags -fno-stack-protector
		# Bug 253127
		sed -e "/^QMAKE_CFLAGS\t/ s:$: -fno-stack-protector-all:" \
		-i "${S}"/mkspecs/common/g++.conf || die "sed ${S}/mkspecs/common/g++.conf failed"
	fi

	# Bug 172219
	sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-e "s:X11R6/::" \
		-i "${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf || die "sed ${S}/mkspecs/$(qt_mkspecs_dir)/qmake.conf failed"

	if [[ ${CHOST} != *-darwin* ]]; then
		sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
			-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
			-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
			-i "${S}"/mkspecs/common/g++.conf || die "sed ${S}/mkspecs/common/g++.conf failed"
	else
		# Set FLAGS *and* remove -arch, since our gcc-apple is multilib
		# crippled (by design) :/
		sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
			-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
			-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=-headerpad_max_install_names ${LDFLAGS}:" \
			-e "s:-arch\s\w*::g" \
			-i "${S}"/mkspecs/common/mac-g++.conf || die "sed ${S}/mkspecs/common/mac-g++.conf failed"

		# Fix configure's -arch settings that appear in qmake/Makefile and also
		# fix arch handling (automagically duplicates our -arch arg and breaks
		# pch). Additionally disable Xarch support.
		sed \
			-e "s:-arch i386::" \
			-e "s:-arch ppc::" \
			-e "s:-arch x86_64::" \
			-e "s:-arch ppc64::" \
			-e "s:-arch \$i::" \
			-e "/if \[ ! -z \"\$NATIVE_64_ARCH\" \]; then/,/fi/ d" \
			-e "s:CFG_MAC_XARCH=yes:CFG_MAC_XARCH=no:g" \
			-e "s:-Xarch_x86_64::g" \
			-e "s:-Xarch_ppc64::g" \
			-i "${S}"/configure "${S}"/mkspecs/common/mac-g++.conf || die "sed ${S}/configure failed"

		# On Snow Leopard don't fall back to 10.5 deployment target.
		[[ ${CHOST} == *-apple-darwin10 ]] && \
			sed -e "s:QMakeVar set QMAKE_MACOSX_DEPLOYMENT_TARGET.*:QMakeVar set QMAKE_MACOSX_DEPLOYMENT_TARGET 10.6:g" \
				-e "s:-mmacosx-version-min=10.[0-9]:-mmacosx-version-min=10.6:g" \
				-i "${S}"/configure "${S}"/mkspecs/common/mac-g++.conf || die "sed ${S}/configure failed"
	fi

	# this one is needed for all systems with a separate -liconv, apart from
	# Darwin, for which the sources already cater for -liconv
	if use !elibc_glibc && [[ ${CHOST} != *-darwin* ]] ; then
		sed \
			-e "s|mac:LIBS += -liconv|LIBS += -liconv|g" \
			-i "${S}"/config.tests/unix/iconv/iconv.pro \
			|| die "sed on iconv.pro failed"
	fi

	# we need some patches for Solaris
	sed -i \
		-e '/^QMAKE_LFLAGS_THREAD/a\QMAKE_LFLAGS_DYNAMIC_LIST = -Wl,--dynamic-list,' \
		"${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf || die
	# use GCC over SunStudio
	sed -i -e '/PLATFORM=solaris-cc/s/cc/g++/' "${S}"/configure || die
	# don't flirt with non-Prefix stuff, we're quite possessive
	sed -i -e '/^QMAKE_\(LIB\|INC\)DIR\(_X11\|_OPENGL\|\)\t/s/=.*$/=/' \
		"${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf || die

	base_src_prepare
}

# @FUNCTION: qt4-build_src_configure
# @DESCRIPTION:
# Default configure phase
qt4-build_src_configure() {
	setqtenv
	myconf="$(standard_configure_options) ${myconf}"

	# this one is needed for all systems with a separate -liconv, apart from
	# Darwin, for which the sources already cater for -liconv
	use !elibc_glibc && [[ ${CHOST} != *-darwin* ]] && \
		myconf="${myconf} -liconv"

	if use glib; then
		local glibflags=""
		# use -I, -L and -l from configure 
		glibflags="$(pkg-config --cflags --libs glib-2.0 gthread-2.0)"
		# avoid the -pthread argument
		myconf="${myconf} ${glibflags//-pthread}"
		unset glibflags
	fi

	# freetype2 include dir is non-standard, thus include it on configure
	if ! use aqua; then
		# use -I from configure
		myconf="${myconf} $(pkg-config --cflags freetype2)"
	fi

	case "${PV}" in
		4.4.*)
			;;
		4.?.*)
			if use aqua ; then
				# On (snow) leopard use the new (frameworked) cocoa code.
				if [[ $(uname -r | cut -d . -f 1) -ge 9 ]] ; then
					myconf="${myconf} -cocoa -framework"

					# We are crazy and build cocoa + qt3support :-)
					if use qt3support; then
						sed -e "/case \"\$PLATFORM,\$CFG_MAC_COCOA\" in/,/;;/ s|CFG_QT3SUPPORT=\"no\"|CFG_QT3SUPPORT=\"yes\"|" \
							-i "${S}/configure"
					fi

					# We need the source's headers, not the installed ones.
					myconf="${myconf} -I${S}/include"

					# Add hint for the framework location.
					myconf="${myconf} -F${QTLIBDIR}"
				fi
			fi
			;;
		*)
			;;
	esac

	echo ./configure ${myconf}
	./configure ${myconf} || die "./configure failed"
	myconf=""
}

# @FUNCTION: qt4-build_src_compile
# @DESCRIPTION: Actual compile phase
qt4-build_src_compile() {
	setqtenv
	# Be backwards compatible for now
	if [[ $EAPI != 2 ]]; then
		qt4-build_src_configure
	fi

	build_directories "${QT4_TARGET_DIRECTORIES}"
}

# @FUNCTION: fix_includes
# @DESCRIPTION:
# For MacOSX we need to add some symlinks when frameworks are
# being used, to avoid complications with some more or less stupid packages.
fix_includes() {
	if use aqua && [[ $(uname -r | cut -d . -f 1) -ge 9 ]] ; then
		# Some packages tend to include <Qt/...>
		dodir "${QTHEADERDIR#${EPREFIX}}"/Qt

		# Fake normal headers when frameworks are installed... eases life later on
		local dest f
		for frw in "${D}${QTLIBDIR}"/*.framework; do
			[[ -e "${frw}"/Headers ]] || continue
			f=$(basename ${frw})
			dest="${QTHEADERDIR#${EPREFIX}}"/${f%.framework}
			dosym "${QTLIBDIR#${EPREFIX}}"/${f}/Headers "${dest}"

			# Link normal headers as well.
			for hdr in "${D}/${QTLIBDIR}/${f}"/Headers/*; do
				h=$(basename ${hdr})
				dosym "${QTLIBDIR#${EPREFIX}}"/${f}/Headers/${h} "${QTHEADERDIR#${EPREFIX}}"/Qt/${h}
			done
		done
	fi
}

# @FUNCTION: qt4-build_src_install
# @DESCRIPTION:
# Perform the actual installation including some library fixes.
qt4-build_src_install() {
	setqtenv
	install_directories "${QT4_TARGET_DIRECTORIES}"
	install_qconfigs
	fix_library_files
	fix_includes
}

# @FUNCTION: setqtenv
setqtenv() {
	# Set up installation directories
	QTBASEDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QTPREFIXDIR=${EPREFIX}/usr
	QTBINDIR=${EPREFIX}/usr/bin
	QTLIBDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QMAKE_LIBDIR_QT=${QTLIBDIR}
	QTPCDIR=${EPREFIX}/usr/$(get_libdir)/pkgconfig
	QTDATADIR=${EPREFIX}/usr/share/qt4
	QTDOCDIR=${EPREFIX}/usr/share/doc/qt-${PV}
	QTHEADERDIR=${EPREFIX}/usr/include/qt4
	QTPLUGINDIR=${QTLIBDIR}/plugins
	QTSYSCONFDIR=${EPREFIX}/etc/qt4
	QTTRANSDIR=${QTDATADIR}/translations
	QTEXAMPLESDIR=${QTDATADIR}/examples
	QTDEMOSDIR=${QTDATADIR}/demos
	QT_INSTALL_PREFIX=${EPREFIX}/usr/$(get_libdir)/qt4
	PLATFORM=$(qt_mkspecs_dir)

	unset QMAKESPEC
}

# @FUNCTION: standard_configure_options
# @DESCRIPTION:
# Sets up some standard configure options, like libdir (if necessary), whether
# debug info is wanted or not.
standard_configure_options() {
	local myconf=""

	[[ $(get_libdir) != "lib" ]] && myconf="${myconf} -L${EPREFIX}/usr/$(get_libdir)"

	# Disable visibility explicitly if gcc version isn't 4
	if [[ "$(gcc-major-version)" -lt "4" ]]; then
		myconf="${myconf} -no-reduce-exports"
	fi

	# precompiled headers doesn't work on hardened, where the flag is masked.
	if use pch; then
		myconf="${myconf} -pch"
	else
		myconf="${myconf} -no-pch"
	fi

	if use debug; then
		myconf="${myconf} -debug -no-separate-debug-info"
	else
		myconf="${myconf} -release -no-separate-debug-info"
	fi

	use aqua && myconf="${myconf} -no-framework"

	# ARCH is set on Gentoo. Qt now falls back to generic on an unsupported
	# $(tc-arch). Therefore we convert it to supported values.
	case "$(tc-arch)" in
		amd64|x64-*) myconf="${myconf} -arch x86_64" ;;
		ppc-macos) myconf="${myconf} -arch ppc" ;;
		ppc|ppc64|ppc-*) myconf="${myconf} -arch powerpc" ;;
		sparc|sparc-*) myconf="${myconf} -arch sparc" ;;
		x86-macos) myconf="${myconf} -arch x86" ;;
		x86|x86-*) myconf="${myconf} -arch i386" ;;
		alpha|arm|ia64|mips|s390|sparc) myconf="${myconf} -arch $(tc-arch)" ;;
		hppa|sh) myconf="${myconf} -arch generic" ;;
		*) die "$(tc-arch) is unsupported by this eclass. Please file a bug." ;;
	esac

	# don't do this in Prefix, or we will end up with non-working stuff
	# on ELF systems, non-Prefix uses ld.so.conf
	use prefix || myconf="${myconf} -no-rpath"

	# 4.6: build qt-core with exceptions or qt-xmlpatterns won't build
	local exceptions=
	case "${PV}" in
		4.6.*)
			if [[ ${PN} != "qt-core" ]] && [[ ${PN} != "qt-xmlpatterns" ]]; then
				exceptions="-no-exceptions"
			fi
		;;
		*)
			[[ ${PN} == "qt-xmlpatterns" ]] || exceptions="-no-exceptions"
		;;
	esac

	# note about -reduce-relocations:
	# That flag seems to introduce major breakage to applications,
	# mostly to be seen as a core dump with the message "QPixmap: Must
	# construct a QApplication before a QPaintDevice" on Solaris
	#   -- Daniel Vergien
	local relocations=
	[[ ${CHOST} != *-solaris* ]] && relocations="-reduce-relocations"

	myconf="${myconf} -platform $(qt_mkspecs_dir) -stl -verbose -largefile -confirm-license
		-prefix ${QTPREFIXDIR} -bindir ${QTBINDIR} -libdir ${QTLIBDIR}
		-datadir ${QTDATADIR} -docdir ${QTDOCDIR} -headerdir ${QTHEADERDIR}
		-plugindir ${QTPLUGINDIR} -sysconfdir ${QTSYSCONFDIR}
		-translationdir ${QTTRANSDIR} -examplesdir ${QTEXAMPLESDIR}
		-demosdir ${QTDEMOSDIR} -silent -fast
		${exceptions}
		${relocations} -nomake examples -nomake demos"

	# Make eclass >= 4.5.x ready
	case "${MY_PV}" in
		4.5.* | 4.6.* )
			myconf="${myconf} -opensource"
			;;
	esac

	echo "${myconf}"
}

# @FUNCTION: build_directories
# @USAGE: < directories >
# @DESCRIPTION:
# Compiles the code in $QT4_TARGET_DIRECTORIES
build_directories() {
	local dirs="$@"
	for x in ${dirs}; do
		cd "${S}"/${x}
		sed -i -e "s:\$\$\[QT_INSTALL_LIBS\]:${EPREFIX}/usr/$(get_libdir)/qt4:g" $(find "${S}" -name '*.pr[io]') "${S}"/mkspecs/common/*.conf || die
		"${S}"/bin/qmake "LIBS+=-L${QTLIBDIR}" "CONFIG+=nostrip" || die "qmake failed"
		emake CC="@echo compiling \$< && $(tc-getCC)" \
			CXX="@echo compiling \$< && $(tc-getCXX)" \
			LINK="@echo linking \$@ && $(tc-getCXX)" || die "emake failed"
	done
}

# @FUNCTION: install_directories
# @USAGE: < directories >
# @DESCRIPTION:
# run emake install in the given directories, which are separated by spaces
install_directories() {
	local dirs="$@"
	for x in ${dirs}; do
		pushd "${S}"/${x} >/dev/null || die "Can't pushd ${S}/${x}"
		emake INSTALL_ROOT="${D}" install || die "emake install failed"
		popd >/dev/null || die "Can't popd from ${S}/${x}"
	done
}

# @ECLASS-VARIABLE: QCONFIG_ADD
# @DESCRIPTION:
# List options that need to be added to QT_CONFIG in qconfig.pri
QCONFIG_ADD="${QCONFIG_ADD:-}"

# @ECLASS-VARIABLE: QCONFIG_REMOVE
# @DESCRIPTION:
# List options that need to be removed from QT_CONFIG in qconfig.pri
QCONFIG_REMOVE="${QCONFIG_REMOVE:-}"

# @ECLASS-VARIABLE: QCONFIG_DEFINE
# @DESCRIPTION:
# List variables that should be defined at the top of QtCore/qconfig.h
QCONFIG_DEFINE="${QCONFIG_DEFINE:-}"

# @FUNCTION: install_qconfigs
# @DESCRIPTION: Install gentoo-specific mkspecs configurations
install_qconfigs() {
	local x
	if [[ -n ${QCONFIG_ADD} || -n ${QCONFIG_REMOVE} ]]; then
		for x in QCONFIG_ADD QCONFIG_REMOVE; do
			[[ -n ${!x} ]] && echo ${x}=${!x} >> "${T}"/${PN}-qconfig.pri
		done
		insinto ${QTDATADIR#${EPREFIX}}/mkspecs/gentoo
		doins "${T}"/${PN}-qconfig.pri || die "installing ${PN}-qconfig.pri failed"
	fi

	if [[ -n ${QCONFIG_DEFINE} ]]; then
		for x in ${QCONFIG_DEFINE}; do
			echo "#define ${x}" >> "${T}"/gentoo-${PN}-qconfig.h
		done
		insinto ${QTHEADERDIR#${EPREFIX}}/Gentoo
		doins "${T}"/gentoo-${PN}-qconfig.h || die "installing ${PN}-qconfig.h failed"
	fi
}

# @FUNCTION: generate_qconfigs
# @DESCRIPTION: Generates gentoo-specific configurations
generate_qconfigs() {
	if [[ -n ${QCONFIG_ADD} || -n ${QCONFIG_REMOVE} || -n ${QCONFIG_DEFINE} || ${CATEGORY}/${PN} == x11-libs/qt-core ]]; then
		local x qconfig_add qconfig_remove qconfig_new
		for x in "${ROOT}${QTDATADIR}"/mkspecs/gentoo/*-qconfig.pri; do
			[[ -f ${x} ]] || continue
			qconfig_add="${qconfig_add} $(sed -n 's/^QCONFIG_ADD=//p' "${x}")"
			qconfig_remove="${qconfig_remove} $(sed -n 's/^QCONFIG_REMOVE=//p' "${x}")"
		done

		# these error checks do not use die because dying in pkg_post{inst,rm}
		# just makes things worse.
		if [[ -e "${ROOT}${QTDATADIR}"/mkspecs/gentoo/qconfig.pri ]]; then
			# start with the qconfig.pri that qt-core installed
			if ! cp "${ROOT}${QTDATADIR}"/mkspecs/gentoo/qconfig.pri \
				"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri; then
				eerror "cp qconfig failed."
				return 1
			fi

			# generate list of QT_CONFIG entries from the existing list
			# including qconfig_add and excluding qconfig_remove
			for x in $(sed -n 's/^QT_CONFIG +=//p' \
				"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri) ${qconfig_add}; do
					hasq ${x} ${qconfig_remove} || qconfig_new="${qconfig_new} ${x}"
			done

			# replace the existing QT_CONFIG list with qconfig_new
			if ! sed -i -e "s/QT_CONFIG +=.*/QT_CONFIG += ${qconfig_new}/" \
				"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri; then
				eerror "Sed for QT_CONFIG failed"
				return 1
			fi

			# create Gentoo/qconfig.h
			if [[ ! -e ${ROOT}${QTHEADERDIR}/Gentoo ]]; then
				if ! mkdir -p "${ROOT}${QTHEADERDIR}"/Gentoo; then
					eerror "mkdir ${QTHEADERDIR}/Gentoo failed"
					return 1
				fi
			fi
			: > "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			for x in "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-*-qconfig.h; do
				[[ -f ${x} ]] || continue
				cat "${x}" >> "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			done
		else
			rm -f "${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri
			rm -f "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			rmdir "${ROOT}${QTDATADIR}"/mkspecs \
				"${ROOT}${QTDATADIR}" \
				"${ROOT}${QTHEADERDIR}"/Gentoo \
				"${ROOT}${QTHEADERDIR}" 2>/dev/null
		fi
	fi
}

# @FUNCTION: qt4-build_pkg_postrm
# @DESCRIPTION: Generate configurations when the package is completely removed
qt4-build_pkg_postrm() {
	generate_qconfigs
}

# @FUNCTION: qt4-build_pkg_postinst
# @DESCRIPTION: Generate configuration, plus throws a message about possible
# breakages and proposed solutions.
qt4-build_pkg_postinst() {
	generate_qconfigs
	echo
	ewarn "After a rebuild or upgrade of Qt, it can happen that Qt plugins (such as Qt"
	ewarn "and KDE styles and widgets) can no longer be loaded. In this situation you"
	ewarn "should recompile the packages providing these plugins. Also, make sure you"
	ewarn "compile the Qt packages, and the packages that depend on it, with the same"
	ewarn "GCC version and the same USE flag settings (especially the debug flag)."
	ewarn
	ewarn "Packages that typically need to be recompiled are kdelibs from KDE4, any"
	ewarn "additional KDE4/Qt4 styles, qscintilla and PyQt4. Before filing a bug report,"
	ewarn "make sure all your Qt4 packages are up-to-date and built with the same"
	ewarn "configuration."
	ewarn
	ewarn "For more information, see http://doc.trolltech.com/${PV%.*}/plugins-howto.html"
	echo
}

# @FUNCTION: skip_qmake_build_patch
# @DESCRIPTION:
# Don't need to build qmake, as it's already installed from qt-core
skip_qmake_build_patch() {
	# Don't need to build qmake, as it's already installed from qt-core
	sed -i -e "s:if true:if false:g" "${S}"/configure || die "Sed failed"
}

# @FUNCTION: skip_project_generation_patch
# @DESCRIPTION:
# Exit the script early by throwing in an exit before all of the .pro files are scanned
skip_project_generation_patch() {
	# Exit the script early by throwing in an exit before all of the .pro files are scanned
	sed -e "s:echo \"Finding:exit 0\n\necho \"Finding:g" \
		-i "${S}"/configure || die "Sed failed"
}

# @FUNCTION: symlink_binaries_to_buildtree
# @DESCRIPTION:
# Symlink generated binaries to buildtree so they can be used during compilation
# time
symlink_binaries_to_buildtree() {
	for bin in qmake moc uic rcc; do
		ln -s ${QTBINDIR}/${bin} "${S}"/bin/ || die "Symlinking ${bin} to ${S}/bin failed."
	done
}

# @FUNCTION: fix_library_files
# @DESCRIPTION:
# Fixes the pathes in *.la, *.prl, *.pc, as they are wrong due to sandbox and
# moves the *.pc-files into the pkgconfig directory
fix_library_files() {
	for libfile in "${D}"/${QTLIBDIR}/{*.la,*.prl,pkgconfig/*.pc}; do
		if [[ -e ${libfile} ]]; then
			sed -i -e "s:${S}/lib:${QTLIBDIR}:g" ${libfile} || die "Sed on ${libfile} failed."
		fi
	done

	# pkgconfig files refer to WORKDIR/bin as the moc and uic locations.  Fix:
	for libfile in "${D}"/${QTLIBDIR}/pkgconfig/*.pc; do
		if [[ -e ${libfile} ]]; then
			sed -i -e "s:${S}/bin:${QTBINDIR}:g" ${libfile} || die "Sed failed"

	# Move .pc files into the pkgconfig directory
		dodir ${QTPCDIR#${EPREFIX}}
		mv ${libfile} "${D}"/${QTPCDIR}/ \
			|| die "Moving ${libfile} to ${D}/${QTPCDIR}/ failed."
		fi
	done

	# Don't install an empty directory
	rmdir "${D}"/${QTLIBDIR}/pkgconfig
}

# @FUNCTION: qt_use
# @USAGE: < flag > [ feature ] [ enableval ]
# @DESCRIPTION:
# This will echo "${enableval}-${feature}" if <flag> is enabled, or
# "-no-${feature} if the flag is disabled. If [feature] is not specified <flag>
# will be used for that. If [enableval] is not specified, it omits the
# assignment-part
qt_use() {
	local flag="${1}"
	local feature="${1}"
	local enableval=

	[[ -n ${2} ]] && feature=${2}
	[[ -n ${3} ]] && enableval="-${3}"

	if use ${flag}; then
		echo "${enableval}-${feature}"
	else
		echo "-no-${feature}"
	fi
}

# @ECLASS-VARIABLE: QT4_BUILT_WITH_USE_CHECK
# @DESCRIPTION:
# The contents of $QT4_BUILT_WITH_USE_CHECK gets fed to built_with_use
# (eutils.eclass), line per line.
#
# Example:
# @CODE
# pkg_setup() {
# 	use qt3support && QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
# 		~x11-libs/qt-gui-${PV} qt3support"
# 	qt4-build_check_use
# }
# @CODE

# Run built_with_use on each flag and print appropriate error messages if any
# flags are missing

_qt_built_with_use() {
	local missing opt pkg flag flags

	if [[ ${1} = "--missing" ]]; then
		missing="${1} ${2}" && shift 2
	fi
	if [[ ${1:0:1} = "-" ]]; then
		opt=${1} && shift
	fi

	pkg=${1} && shift

	for flag in "${@}"; do
		flags="${flags} ${flag}"
		if ! built_with_use ${missing} ${opt} ${pkg} ${flag}; then
			flags="${flags}*"
		else
			[[ ${opt} = "-o" ]] && return 0
		fi
	done
	if [[ "${flags# }" = "${@}" ]]; then
		return 0
	fi
	if [[ ${opt} = "-o" ]]; then
		eerror "This package requires '${pkg}' to be built with any of the following USE flags: '$*'."
	else
		eerror "This package requires '${pkg}' to be built with the following USE flags: '${flags# }'."
	fi
	return 1
}

# @FUNCTION: qt4-build_check_use
# @DESCRIPTION:
# Check if the listed packages in $QT4_BUILT_WITH_USE_CHECK are built with the
# USE flags listed.
#
# If any of the required USE flags are missing, an eerror will be printed for
# each package with missing USE flags.
qt4-build_check_use() {
	local line missing
	while read line; do
		[[ -z ${line} ]] && continue
		if ! _qt_built_with_use ${line}; then
			missing=true
		fi
	done <<< "${QT4_BUILT_WITH_USE_CHECK}"
	if [[ -n ${missing} ]]; then
		echo
		eerror "Flags marked with an * are missing."
		die "Missing USE flags found"
	fi
}

# @FUNCTION: qt_mkspecs_dir
# @RETURN: the specs-directory w/o path
# @DESCRIPTION:
# Allows us to define which mkspecs dir we want to use.
qt_mkspecs_dir() {
	# Allows us to define which mkspecs dir we want to use.
	local spec

	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec="freebsd" ;;
		*-openbsd*)
			spec="openbsd" ;;
		*-netbsd*)
			spec="netbsd" ;;
		*-darwin*)
			if use aqua; then
				# mac with carbon/cocoa
				spec="macx"
			else
				# darwin/mac with x11
				spec="darwin"
			fi ;;
		*-solaris*)
			spec="solaris" ;;
		*-linux-*|*-linux)
			spec="linux" ;;
		*)
			die "Unknown CHOST, no platform choosen."
	esac

	CXX=$(tc-getCXX)
	if [[ ${CXX/g++/} != ${CXX} ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX/icpc/} != ${CXX} ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler ${CXX}."
	fi
	if [[ -n "${LIBDIR/lib}" ]]; then
		spec="${spec}-${LIBDIR/lib}"
	fi

	# Add -64 for 64bit profiles
	if use x64-freebsd ||
		use amd64-linux ||
		use x64-macos ||
		use x64-solaris ||
		use sparcv9-solaris ;
	then
		spec="${spec}-64"
	fi

	echo "${spec}"
}

case ${EAPI:-0} in
	0|1) EXPORT_FUNCTIONS pkg_setup src_unpack src_compile src_install pkg_postrm pkg_postinst ;;
	2) EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install pkg_postrm pkg_postinst ;;
esac
