# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.6.5-r2.ebuild,v 1.17 2010/07/31 19:14:08 arfrever Exp $

EAPI="2"

inherit autotools eutils flag-o-matic multilib pax-utils python toolchain-funcs

MY_P="Python-${PV}"

PATCHSET_REVISION="4"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.6"
PYTHON_ABI="${SLOT}"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="aqua -berkdb build doc elibc_uclibc examples gdbm ipv6 +ncurses +readline sqlite +ssl +threads tk +wide-unicode wininst +xml"

# NOTE: dev-python/{elementtree,celementtree,pysqlite}
#       do not conflict with the ones in python proper. - liquidx

RDEPEND=">=app-admin/eselect-python-20091230
		>=sys-libs/zlib-1.1.3
		!m68k-mint? ( virtual/libffi )
		virtual/libintl
		!build? (
			berkdb? ( || (
				sys-libs/db:4.7
				sys-libs/db:4.6
				sys-libs/db:4.5
				sys-libs/db:4.4
				sys-libs/db:4.3
				sys-libs/db:4.2
			) )
			gdbm? ( sys-libs/gdbm )
			ncurses? (
				>=sys-libs/ncurses-5.2
				readline? ( >=sys-libs/readline-4.1 )
			)
			sqlite? ( >=dev-db/sqlite-3 )
			ssl? ( dev-libs/openssl )
			tk? ( >=dev-lang/tk-8.0 )
			xml? ( >=dev-libs/expat-2 )
		)
		doc? ( dev-python/python-docs:${SLOT} )"
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		!sys-devel/gcc[libffi]"
RDEPEND+=" !build? ( app-misc/mime-types )"
PDEPEND="app-admin/python-updater"

PROVIDE="virtual/python"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_pkg_setup

	if use berkdb; then
		ewarn "\"bsddb\" module is out-of-date and no longer maintained inside dev-lang/python. It has"
		ewarn "been additionally removed in Python 3. You should use external, still maintained \"bsddb3\""
		ewarn "module provided by dev-python/bsddb3 which supports both Python 2 and Python 3."
	fi
}

src_prepare() {
	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if ! tc-is-cross-compiler; then
		rm "${WORKDIR}/${PV}"/*_all_crosscompile.patch
	fi

	# hardcoding GNU specifics breaks platforms not using GNU binutils
	case $($(tc-getAS) --noexecstack -v 2>&1 </dev/null) in
		*"GNU Binutils"*) # GNU as with noexecstack support
			:
		;;
		*)
			EPATCH_EXCLUDE=07_all_ctypes_execstack.patch
		;;
	esac
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PV}"

	# apply before Gentoo libdir comes into effect
	# these patches get rid of unwanted looking around in the host OS
	epatch "${FILESDIR}"/${PN}-2.6.5-readline-prefix.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-no-usrlocal.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-use-first-bsddb-found.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-no-bsddb185.patch

	# Darwin/OSX Framework related patches and tweaks
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-bundle.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-no-special-darwin-libffi.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-darwin-no-framework-lookup.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-mac.patch
	epatch "${FILESDIR}"/${PN}-2.6.5-mac-just-prefix.patch # injects @@LIBDIR
	# need this to have _NSGetEnviron being used, which by default isn't, also
	# in a non-Framework build (use !aqua)   upstream doesn't build like this
	[[ ${CHOST} == *-darwin* ]] && use !aqua && \
		append-flags -DWITH_NEXT_FRAMEWORK
	# this activates stuff from python-2.6.2-mac.patch (2.7+ has this fixed)
	sed -i -e "s:@@APPLICATIONS_DIR@@:${EPREFIX}/Applications:g" \
		Mac/Makefile.in \
		Mac/IDLE/Makefile.in \
		Mac/Tools/Doc/setup.py \
		Mac/PythonLauncher/Makefile.in || die
	# we need to set this to prevent the framework path to be used in an OSX
	# Framework build, which causes misc unwanted effects in our UNIX-savvy env
	sed -i -e '/-DPREFIX=/s:$(prefix):'"${EPREFIX}/usr"':' \
		-e '/-DEXEC_PREFIX=/s:$(exec_prefix):'"${EPREFIX}/usr"':' \
		Makefile.pre.in || die

	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die "sed failed to replace @@GENTOO_LIBDIR@@"

	# Fix os.utime() on hppa. utimes it not supported but unfortunately reported as working - gmsoft (22 May 04)
	# PLEASE LEAVE THIS FIX FOR NEXT VERSIONS AS IT'S A CRITICAL FIX !!!
	[[ "${ARCH}" == "hppa" ]] && sed -e "s/utimes //" -i "${S}/configure"

	if ! use wininst; then
		# Remove Microsoft Windows executables.
		rm Lib/distutils/command/wininst-*.exe
	fi

	# build static for mint
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${PN}-2.6.2-mint.patch

	# do not use 'which' to find binaries, but go through the PATH.
	epatch "${FILESDIR}"/${PN}-2.4.4-ld_so_aix-which.patch
	# at least IRIX starts spitting out ugly errors, but we want to use Prefix
	# grep anyway
	epatch "${FILESDIR}"/${PN}-2.5.1-no-hardcoded-grep.patch
	# make it compile on IRIX as well
	epatch "${FILESDIR}"/${PN}-2.6.5-irix.patch
	# and generate a libpython2.6.so
	epatch "${FILESDIR}"/${PN}-2.6-irix-libpython2.6.patch
	# AIX sometimes keeps ".nfsXXX" files around: ignore them in distutils
	epatch "${FILESDIR}"/${PN}-2.5.1-distutils-aixnfs.patch
	# AIX 5.2 does not support sem_timedwait for multiprocessing module
	epatch "${FILESDIR}"/${PN}-2.6-aix-multiprocessing.patch
	# this fails to compile on OpenSolaris at least, do we need it?
	epatch "${FILESDIR}"/${PN}-2.6.2-no-sunaudiodev.patch
	# 64-bits Solaris 8-10 have a missing libcrypt symlink
	epatch "${FILESDIR}"/${PN}-2.6.2-solaris64-crypt.patch
	# fixes compilation on more recent OpenSolaris, from them
	epatch "${FILESDIR}"/${PN}-2.6.4-netpacket-solaris.patch
	# http://bugs.python.org/issue6308
	epatch "${FILESDIR}"/${PN}-2.6.2-termios-noqnx.patch
	# build shared library on aix #278845
	epatch "${FILESDIR}"/${PN}-2.6.2-aix-shared.patch
	# hpux before 11.31
	epatch "${FILESDIR}"/${PN}-2.6.2-missing-SEM_FAILED.patch

	# patch to make python behave nice with interix. There is one part
	# maybe affecting other x86-platforms, thus conditional.
	if [[ ${CHOST} == *-interix* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.6.5-interix-noffi.patch
		# this one could be applied unconditionally, but to keep it
		# clean, I do it together with the conditional one.
		epatch "${FILESDIR}"/${PN}-2.5.1-interix-sleep.patch
		# some more modules fixed (_multiprocessing, dl)
		epatch "${FILESDIR}"/${PN}-2.6.5-interix-modules.patch
		# -r2 because of 12_all_check_availability_of_nis_headers
		epatch "${FILESDIR}"/${PN}-2.6.4-r2-interix-nis.patch
	fi

	# Fix OtherFileTests.testStdin() not to assume
	# that stdin is a tty for bug #248081.
	sed -e "s:'osf1V5':'osf1V5' and sys.stdin.isatty():" -i Lib/test/test_file.py || die "sed failed"

	eautoreconf
}

src_configure() {
	# Apparently, no one knows how to solved this as-needed failure.
	# bug 298674 Apply workaround for now. (don't do it on interix - compiler
	# will fail :))
	[[ ${CHOST} != *-interix* ]] &&
		use prefix && append-ldflags $(no-as-needed)
	# Disable extraneous modules with extra dependencies.
	if use build; then
		export PYTHON_DISABLE_MODULES="dbm _bsddb gdbm _curses _curses_panel readline _sqlite3 _tkinter _elementtree pyexpat"
		export PYTHON_DISABLE_SSL="1"
	else
		# dbm module can be linked against berkdb or gdbm.
		# Defaults to gdbm when both are enabled, #204343.
		local disable
		use berkdb   || use gdbm || disable+=" dbm"
		use berkdb   || disable+=" _bsddb"
		use gdbm     || disable+=" gdbm"
		use ncurses  || disable+=" _curses _curses_panel"
		use readline || disable+=" readline"
		use sqlite   || disable+=" _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL="1"
		use tk       || disable+=" _tkinter"
		use xml      || disable+=" _elementtree pyexpat" # _elementtree uses pyexpat.
		use x64-macos && disable+=" Nav _Qt" # Carbon
		export PYTHON_DISABLE_MODULES="${disable}"

		if ! use xml; then
			ewarn "You have configured Python without XML support."
			ewarn "This is NOT a recommended configuration as you"
			ewarn "may face problems parsing any XML documents."
		fi
	fi

	if [[ -n "${PYTHON_DISABLE_MODULES}" ]]; then
		einfo "Disabled modules: ${PYTHON_DISABLE_MODULES}"
	fi

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
	fi

	# http://bugs.gentoo.org/show_bug.cgi?id=302137
	if [[ ${CHOST} == powerpc-*-darwin* ]] && \
		( is-flag "-mtune=*" || is-flag "-mcpu=*" ) ;
	then
		replace-flags -O2 -O3
		replace-flags -Os -O3  # comment #14
	fi

	if tc-is-cross-compiler; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure --{build,host}=${CBUILD} || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e "/^HOSTPYTHON/s:=.*:=./hostpython:" \
			-e "/^HOSTPGEN/s:=.*:=./Parser/hostpgen:" \
			Makefile.pre.in || die "sed failed"
	fi

	# Export CXX so it ends up in /usr/lib/python2.X/config/Makefile.
	tc-export CXX

	# Set LDFLAGS so we link modules with -lpython2.6 correctly.
	# Needed on FreeBSD unless Python 2.6 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# python defaults to use 'cc_r' on aix
	[[ ${CHOST} == *-aix* ]] && myconf="${myconf} --with-gcc=$(tc-getCC)"

	# Don't include libmpc on IRIX - it is only available for 64bit MIPS4
	[[ ${CHOST} == *-irix* ]] && export ac_cv_lib_mpc_usconfig=no

	# Interix poll is broken
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no

	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	# we need this to get pythonw, the GUI version of python
	# --enable-framework and --enable-shared are mutually exclusive:
	# http://bugs.python.org/issue5809
	use aqua \
		&& myconf="${myconf} --enable-framework=${EPREFIX}/usr/lib" \
		|| myconf="${myconf} --enable-shared"

	# note: for a framework build we need to use ucs2 because OSX
	# uses that internally too:
	# http://bugs.python.org/issue763708
	OPT="" econf \
		--with-fpectl \
		$(use_enable ipv6) \
		$(use_with threads) \
		$( (use wide-unicode && use !aqua) && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2") \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-libc="" \
		--with-system-ffi \
		${myconf}
}

src_test() {
	# Tests will not work when cross compiling.
	if tc-is-cross-compiler; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Byte compiling should be enabled here.
	# Otherwise test_import fails.
	python_enable_pyc

	# Skip failing tests.
	local skip_tests="distutils httpservers minidom pyexpat sax tcl"

	# test_ctypes fails with PAX kernel (bug #234498).
	host-is-pax && skip_tests+=" ctypes"

	for test in ${skip_tests}; do
		mv "${S}/Lib/test/test_${test}.py" "${T}"
	done

	# Rerun failed tests in verbose mode (regrtest -w).
	EXTRATESTOPTS="-w" emake test
	local result="$?"

	for test in ${skip_tests}; do
		mv "${T}/test_${test}.py" "${S}/Lib/test/test_${test}.py"
	done

	elog "The following tests have been skipped:"
	for test in ${skip_tests}; do
		elog "test_${test}.py"
	done

	elog "If you'd like to run them, you may:"
	elog "cd '${EPREFIX}$(python_get_libdir)/test'"
	elog "and run the tests separately."

	python_disable_pyc

	if [[ "${result}" -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	[[ -z "${ED}" ]] && ED="${D%/}${EPREFIX}/"

	[[ ${CHOST} == *-mint* ]] && keepdir /usr/lib/python${SLOT}/lib-dynload/
	# do not make multiple targets in parallel when there are broken
	# sharedmods (during bootstrap), would build them twice in parallel.
	if use aqua ; then
		local fwdir="${EPREFIX}"/usr/$(get_libdir)/Python.framework

		# let the makefiles do their thing
		emake -j1 CC="$(tc-getCC)" DESTDIR="${D}" STRIPFLAG= frameworkinstall || die "emake frameworkinstall failed"
		emake DESTDIR="${D}" maninstall || die "emake maninstall failed"

		# avoid framework incompatability, degrade to a normal UNIX lib
		mkdir -p "${ED}"/usr/$(get_libdir)
		cp "${D}${fwdir}"/Versions/${SLOT}/Python \
			"${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib || die
		chmod u+w "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		install_name_tool \
			-id "${EPREFIX}"/usr/$(get_libdir)/libpython${SLOT}.dylib \
			"${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		chmod u-w "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib
		cp "${S}"/libpython${SLOT}.a \
			"${ED}"/usr/$(get_libdir)/ || die

		# rebuild python executable to be the non-pythonw (python wrapper)
		# version so we don't get framework crap
		$(tc-getCC) "${ED}"/usr/$(get_libdir)/libpython${SLOT}.dylib \
			-o "${ED}"/usr/bin/python${SLOT} \
			Modules/python.o || die

		# don't install the "Current" symlink, will always conflict
		rm "${D}${fwdir}"/Versions/Current || die
		# update whatever points to it, eselect-python sets them
		rm "${D}${fwdir}"/{Headers,Python,Resources} || die

		# remove unversioned files (that are not made versioned below)
		pushd "${ED}"/usr/bin > /dev/null
		rm -f python python-config python${SLOT}-config
		# python${SLOT} was created above
		for f in pythonw smtpd${SLOT}.py pydoc idle ; do
			rm -f ${f} ${f}${SLOT}
		done
		# pythonw needs to remain in the framework (that's the whole
		# reason we go through this framework hassle)
		ln -s ../lib/Python.framework/Versions/${SLOT}/bin/pythonw2.6 || die
		# copy the scripts to we can fix their shebangs
		for f in 2to3 pydoc${SLOT} idle${SLOT} python${SLOT}-config ; do
			cp "${D}${fwdir}"/Versions/${SLOT}/bin/${f} . || die
			sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/python'"${SLOT}" \
				${f} || die
		done
		# "fix" to have below collision fix not to bail
		mv pydoc${SLOT} pydoc || die
		mv idle${SLOT} idle || die
		popd > /dev/null

		# basically we don't like the framework stuff at all, so just move
		# stuff around or add some symlinks to make our life easier
		mkdir -p "${ED}"/usr
		mv "${D}${fwdir}"/Versions/${SLOT}/share \
			"${ED}"/usr/ || die "can't move share"
		# get includes just UNIX style
		mkdir -p "${ED}"/usr/include
		mv "${D}${fwdir}"/Versions/${SLOT}/include/python${SLOT} \
			"${ED}"/usr/include/ || die "can't move include"
		pushd "${D}${fwdir}"/Versions/${SLOT}/include > /dev/null
		ln -s ../../../../../include/python${SLOT} || die
		popd > /dev/null
		# remove now dead symlink
		rm "${ED}"/usr/lib/python${SLOT}/config/libpython${SLOT}.a

		# same for libs
		# NOTE: can't symlink the entire dir, because a real dir already exists
		# on upgrade (site-packages), however since we h4x0rzed python to
		# actually look into the UNIX-style dir, we just switch them around.
		mkdir -p "${ED}"/usr/$(get_libdir)
		mv "${D}${fwdir}"/Versions/${SLOT}/lib/python${SLOT} \
			"${ED}"/usr/lib/ || die "can't move python${SLOT}"
		pushd "${D}${fwdir}"/Versions/${SLOT}/lib > /dev/null
		ln -s ../../../../python${SLOT} || die
		popd > /dev/null

		# fix up Makefile
		sed -i \
			-e '/^LINKFORSHARED=/s/_PyMac_Error.*$/PyMac_Error/' \
			-e '/^LDFLAGS=/s/=.*$/=/' \
			-e '/^prefix=/s:=.*$:= '"${EPREFIX}"'/usr:' \
			-e '/^PYTHONFRAMEWORK=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKDIR=/s/=.*$/= no-framework/' \
			-e '/^PYTHONFRAMEWORKPREFIX=/s/=.*$/=/' \
			-e '/^PYTHONFRAMEWORKINSTALLDIR=/s/=.*$/=/' \
			-e '/^LDLIBRARY=/s:=.*$:libpython$(VERSION).dylib:' \
			"${ED}"/usr/lib/python${SLOT}/config/Makefile || die

		# add missing version.plist file
		mkdir -p "${D}${fwdir}"/Versions/${SLOT}/Resources
		cat > "${D}${fwdir}"/Versions/${SLOT}/Resources/version.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildVersion</key>
	<string>1</string>
	<key>CFBundleShortVersionString</key>
	<string>${PV}</string>
	<key>CFBundleVersion</key>
	<string>${PV}</string>
	<key>ProjectName</key>
	<string>Python</string>
	<key>SourceVersion</key>
	<string>${PV}</string>
</dict>
</plist>
EOF
	else
		emake DESTDIR="${D}" altinstall || die "emake altinstall failed"
		emake DESTDIR="${D}" maninstall || die "emake maninstall failed"
	fi
	python_clean_installation_image -q

	mv "${ED}usr/bin/python${SLOT}-config" "${ED}usr/bin/python-config-${SLOT}"

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/2to3" "${ED}usr/bin/2to3-${SLOT}"
	mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${SLOT}"
	mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${SLOT}"
	mv "${ED}usr/share/man/man1/python.1" "${ED}usr/share/man/man1/python${SLOT}.1"
	rm -f "${ED}usr/bin/smtpd.py"

	# http://src.opensolaris.org/source/xref/jds/spec-files/trunk/SUNWPython.spec
	# These #defines cause problems when building c99 compliant python modules
	# http://bugs.python.org/issue1759169
	[[ ${CHOST} == *-solaris* ]] && dosed -e \
		's:^\(^#define \(_POSIX_C_SOURCE\|_XOPEN_SOURCE\|_XOPEN_SOURCE_EXTENDED\).*$\):/* \1 */:' \
		 /usr/include/python${SLOT}/pyconfig.h

	if use build; then
		rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{bsddb,idlelib,lib-tk,sqlite3,test}
	else
		use elibc_uclibc && rm -fr "${ED}$(python_get_libdir)/"{bsddb/test,test}
		use berkdb || rm -fr "${ED}$(python_get_libdir)/"{bsddb,test/test_bsddb*}
		use sqlite || rm -fr "${ED}$(python_get_libdir)/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{idlelib,lib-tk}
	fi

	use threads || rm -fr "${ED}$(python_get_libdir)/multiprocessing"

	prep_ml_includes $(python_get_includedir)

	dodoc Misc/{ACKS,HISTORY,NEWS} || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}/Tools" || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT} || die "newinitd failed"
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT} || die "newconfd failed"

	# Do not install empty directory.
	rmdir "${ED}$(python_get_libdir)/lib-old"

	# fix invalid shebang /usr/local/bin/python
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/python' \
		"${ED}"/usr/$(get_libdir)/python${SLOT}/cgi.py
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version "${CATEGORY}/${PN}:2.6" && ! has_version "${CATEGORY}/${PN}:2.7"; then
		python_updater_warning="1"
	fi
}

eselect_python_update() {
	local eselect_python_options
	[[ "$(eselect python show)" == "python2."* ]] && eselect_python_options="--python2"

	# Create python2 symlink.
	eselect python update --python2 > /dev/null

	eselect python update ${eselect_python_options}
}

pkg_postinst() {
	eselect_python_update

	python_mod_optimize -f -x "/(site-packages|test|tests)/" $(python_get_libdir)

	if [[ "${python_updater_warning}" == "1" ]]; then
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ewarn "You have just upgraded from an older version of Python."
		ewarn "You should run 'python-updater \${options}' to rebuild Python modules."
		ewarn
		ewarn "\e[1;31m************************************************************************\e[0m"
		ewarn
		ebeep 12
	fi
}

pkg_postrm() {
	eselect_python_update

	python_mod_cleanup $(python_get_libdir)
}
