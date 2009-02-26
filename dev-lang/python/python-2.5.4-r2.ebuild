# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.5.4-r2.ebuild,v 1.2 2009/02/10 16:11:57 neurogeek Exp $

# NOTE about python-portage interactions :
# - Do not add a pkg_setup() check for a certain version of portage
#   in dev-lang/python. It _WILL_ stop people installing from
#   Gentoo 1.4 images.

EAPI="prefix 1"

inherit eutils autotools flag-o-matic python multilib versionator toolchain-funcs alternatives libtool

# we need this so that we don't depends on python.eclass
PYVER_MAJOR=$(get_major_version)
PYVER_MINOR=$(get_version_component_range 2)
PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"

MY_P="Python-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
		 mirror://gentoo/python-gentoo-patches-${PV}.tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.5"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+xml ncurses gdbm ssl readline tk berkdb ipv6 build ucs2 sqlite doc +threads examples elibc_uclibc wininst"

# NOTE: dev-python/{elementtree,celementtree,pysqlite,ctypes,cjkcodecs}
#       do not conflict with the ones in python proper. - liquidx

DEPEND=">=sys-libs/zlib-1.1.3
		!build? (
			sqlite? ( >=dev-db/sqlite-3 )
			tk? ( >=dev-lang/tk-8.0 )
			ncurses? ( >=sys-libs/ncurses-5.2
						readline? ( >=sys-libs/readline-4.1 ) )
			berkdb? ( || ( sys-libs/db:4.5 sys-libs/db:4.4 sys-libs/db:4.3
							sys-libs/db:4.2 ) )
			gdbm? ( sys-libs/gdbm )
			ssl? ( dev-libs/openssl )
			doc? ( dev-python/python-docs:2.5 )
		xml? ( dev-libs/expat )
	)"

# NOTE: changed RDEPEND to PDEPEND to resolve bug 88777. - kloeri
# NOTE: added blocker to enforce correct merge order for bug 88777. - zmedico

PDEPEND="${DEPEND} app-admin/python-updater"
PROVIDE="virtual/python"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if tc-is-cross-compiler ; then
		[[ $(python -V 2>&1) != "Python ${PV}" ]] && \
			die "Crosscompiling requires the same host and build versions."
		epatch "${FILESDIR}"/python-2.4.4-test-cross.patch
	else
		rm "${WORKDIR}/${PV}"/*_all_crosscompile.patch
	fi

	# stupidos hardcoding GNU specifics
	[[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* || ${CHOST} == *bsd* ]] || \
		EPATCH_EXCLUDE=21_all_ctypes-execstack.patch
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PV}"
	sed -i -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):g" \
		Lib/distutils/command/install.py \
		Lib/distutils/sysconfig.py \
		Lib/site.py \
		Makefile.pre.in \
		Modules/Setup.dist \
		Modules/getpath.c \
		setup.py || die

	# fix os.utime() on hppa. utimes it not supported but unfortunately reported
	# as working - gmsoft (22 May 04)
	# PLEASE LEAVE THIS FIX FOR NEXT VERSIONS AS IT'S A CRITICAL FIX !!!
	[ "${ARCH}" = "hppa" ] && sed -e 's/utimes //' -i "${S}"/configure

	if ! use wininst; then
		# remove microsoft windows executables
		rm Lib/distutils/command/wininst-*.exe
	fi

	# build static for mint
	[[ ${CHOST} == *-mint* ]] && epatch "${FILESDIR}"/${PN}-2.5.1-mint.patch

	epatch "${FILESDIR}"/${PN}-2.4.4-darwin-fsf-gcc.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-bundle.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-libpython2.5.patch
	# to build libpython.dylib, we need -fno-common, which python doesn't use,
	# and to have _NSGetEnviron being used, which by default it isn't...
	[[ ${CHOST} == *-darwin* ]] && \
		append-flags -fno-common -DWITH_NEXT_FRAMEWORK

	use prefix && epatch "${FILESDIR}"/${PN}-2.5.1-no-usrlocal.patch

	epatch "${FILESDIR}"/${PN}-2.5.1-darwin-gcc-version.patch

	# set RUNSHARED for 'regen' in Lib/plat-*
	epatch "${FILESDIR}"/${PN}-2.5.1-platdir-runshared.patch

	epatch "${FILESDIR}"/${PN}-2.5.1-hpux-ldshared.patch
	epatch "${FILESDIR}"/${PN}-2.4.4-ld_so_aix-which.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-aix-ldshared.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-no-hardcoded-grep.patch
	epatch "${FILESDIR}"/${P}-irix.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-distutils-aixnfs.patch

	# patch to make python behave nice with interix. There is one part
	# maybe affecting other x86-platforms, thus conditional.
	if [[ ${CHOST} == *-interix* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.5.1-interix.patch
		# this one could be applied unconditionally, but to keep it
		# clean, I do it together with the conditional one.
		epatch "${FILESDIR}"/${PN}-2.5.1-interix-sleep.patch
	fi

	eautoreconf
}

src_configure() {
	# disable extraneous modules with extra dependencies
	if use build; then
		export PYTHON_DISABLE_MODULES="readline pyexpat dbm gdbm bsddb _curses _curses_panel _tkinter _sqlite3"
		export PYTHON_DISABLE_SSL=1
	else
		# dbm module can link to berkdb or gdbm
		# defaults to gdbm when both are enabled, #204343
		local disable
		use berkdb   || use gdbm || disable="${disable} dbm"
		use berkdb   || disable="${disable} bsddb"
		use xml      || disable="${disable} pyexpat"
		use gdbm     || disable="${disable} gdbm"
		use ncurses  || disable="${disable} _curses _curses_panel"
		use readline || disable="${disable} readline"
		use sqlite   || disable="${disable} _sqlite3"
		use ssl      || export PYTHON_DISABLE_SSL=1
		use tk       || disable="${disable} _tkinter"
		export PYTHON_DISABLE_MODULES="${disable}"
	fi

	if use !xml; then
		ewarn "You have configured Python without XML support."
		ewarn "This is NOT a recommended configuration as you"
		ewarn "may face problems parsing any XML documents."
	fi

	einfo "Disabled modules: $PYTHON_DISABLE_MODULES"
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	filter-flags -malign-double

	# Seems to no longer be necessary
	#[ "${ARCH}" = "amd64" ] && append-flags -fPIC
	[ "${ARCH}" = "alpha" ] && append-flags -fPIC

	# http://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flag -O3; then
	   is-flag -fstack-protector-all && replace-flags -O3 -O2
	   use hardened && replace-flags -O3 -O2
	fi

	# See #228905
	if [[ $(gcc-major-version) -ge 4 ]]; then
		append-flags -fwrapv
	fi

	export OPT="${CFLAGS}"

	local myconf

	# super-secret switch. don't use this unless you know what you're
	# doing. enabling UCS2 support will break your existing python
	# modules
	use ucs2 \
		&& myconf="${myconf} --enable-unicode=ucs2" \
		|| myconf="${myconf} --enable-unicode=ucs4"

	use threads \
		&& myconf="${myconf} --with-threads" \
		|| myconf="${myconf} --without-threads"

	src_configure

	if tc-is-cross-compiler ; then
		OPT="-O1" CFLAGS="" LDFLAGS="" CC="" \
		./configure || die "cross-configure failed"
		emake python Parser/pgen || die "cross-make failed"
		mv python hostpython
		mv Parser/pgen Parser/hostpgen
		make distclean
		sed -i \
			-e '/^HOSTPYTHON/s:=.*:=./hostpython:' \
			-e '/^HOSTPGEN/s:=.*:=./Parser/hostpgen:' \
			Makefile.pre.in || die
	fi

	# export CXX so it ends up in /usr/lib/python2.x/config/Makefile
	tc-export CXX

	# set LDFLAGS so we link modules with -lpython2.5 correctly.
	# Needed on FreeBSD unless python2.5 is already installed.
	# Please query BSD team before removing this!
	append-ldflags "-L."

	# python defaults to use 'cc_r' on aix
	[[ ${CHOST} == *-aix* ]] && myconf="${myconf} --with-gcc=$(tc-getCC)"
	# http://bugs.python.org/issue4026
	if [[ ${CHOST} == *-aix6* ]]; then
		sed -i -e 's:-lm :-lm -lbsd :' Modules/ld_so_aix || die "sed failure"
	fi

	econf \
		--with-fpectl \
		--enable-shared \
		`use_enable ipv6` \
		--infodir='${prefix}'/share/info \
		--mandir='${prefix}'/share/man \
		--with-libc='' \
		${myconf} || die
	emake || die "Parallel make failed"
	if [[ ${CHOST} == *-darwin* ]] ; then
		# create libpython on Darwin
		emake libpython2.5.dylib || die
	fi
}

src_install() {
	dodir /usr
	[[ ${CHOST} == *-mint* ]] && keepdir /usr/lib/python${PYVER}/lib-dynload/
	src_configure
	make DESTDIR="${D}" altinstall maninstall || die

	mv "${ED}"/usr/bin/python${PYVER}-config \
		"${ED}"/usr/bin/python-config-${PYVER}

	# Fix slotted collisions
	mv "${ED}"/usr/bin/pydoc "${ED}"/usr/bin/pydoc${PYVER}
	mv "${ED}"/usr/bin/idle "${ED}"/usr/bin/idle${PYVER}
	mv "${ED}"/usr/share/man/man1/python.1 \
		"${ED}"/usr/share/man/man1/python${PYVER}.1
	rm -f "${ED}"/usr/bin/smtpd.py

	# While we're working on the config stuff... Let's fix the OPT var
	# so that it doesn't have any opts listed in it. Prevents the problem
	# with compiling things with conflicting opts later.
	dosed -e 's:^OPT=.*:OPT=-DNDEBUG:' \
			/usr/$(get_libdir)/python${PYVER}/config/Makefile

	if use build ; then
		rm -rf \
			"${ED}"/usr/$(get_libdir)/python${PYVER}/{test,encodings,email,lib-tk,bsddb/test}
	else
		use elibc_uclibc && rm -rf \
			"${ED}"/usr/$(get_libdir)/python${PYVER}/{test,bsddb/test}
		use berkdb || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/bsddb
		use tk || rm -rf "${ED}"/usr/$(get_libdir)/python${PYVER}/lib-tk
	fi

	prep_ml_includes usr/include/python${PYVER}

	# The stuff below this line extends from 2.1, and should be deprecated
	# in 2.3, or possibly can wait till 2.4

	# seems like the build do not install Makefile.pre.in anymore
	# it probably shouldn't - use DistUtils, people!
	insinto /usr/$(get_libdir)/python${PYVER}/config
	doins "${S}"/Makefile.pre.in

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}"/Tools || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT}
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT}
}

pkg_postrm() {
	local mansuffix=$(ecompress --suffix)
	python_makesym
	alternatives_auto_makesym "/usr/bin/idle" "idle[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/pydoc" "pydoc[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python-config" \
								"python-config-[0-9].[0-9]"

	alternatives_auto_makesym "/usr/share/man/man1/python.1${mansuffix}" \
								"python[0-9].[0-9].1${mansuffix}"

	python_mod_cleanup /usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || \
		python_mod_cleanup /usr/$(get_libdir)/python${PYVER}
}

pkg_postinst() {
	local myroot
	myroot=$(echo $EROOT | sed 's:/$::')
	local mansuffix=$(ecompress --suffix)

	python_makesym
	alternatives_auto_makesym "/usr/bin/idle" "idle[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/pydoc" "pydoc[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python-config" \
								"python-config-[0-9].[0-9]"

	alternatives_auto_makesym "/usr/share/man/man1/python.1${mansuffix}" \
								"python[0-9].[0-9].1${mansuffix}"

	python_mod_optimize
	python_mod_optimize -x "(site-packages|test)" \
						/usr/lib/python${PYVER}
	[[ "$(get_libdir)" == "lib" ]] || \
		python_mod_optimize -x "(site-packages|test)" \
							/usr/$(get_libdir)/python${PYVER}

	# workaround possible python-upgrade-breaks-portage situation
	if [ ! -f ${myroot}/usr/lib/portage/pym/portage.py ]; then
		if [ -f ${myroot}/usr/lib/python2.3/site-packages/portage.py ]; then
			einfo "Working around possible python-portage upgrade breakage"
			mkdir -p ${myroot}/usr/lib/portage/pym
			cp \
			${myroot}/usr/lib/python2.4/site-packages/{portage,xpak,output,cvstree,getbinpkg,emergehelp,dispatch_conf}.py \
				${myroot}/usr/lib/portage/pym
			python_mod_optimize /usr/lib/portage/pym
		fi
	fi

	echo
	ewarn
	ewarn "If you have just upgraded from an older version of python you will"
	ewarn "need to run:"
	ewarn
	ewarn "${EPREFIX}/usr/sbin/python-updater"
	ewarn
	ewarn "This will automatically rebuild all the python dependent modules"
	ewarn "to run with python-${PYVER}."
	ewarn
	ewarn "Your original Python is still installed and can be accessed via"
	ewarn "${EPREFIX}/usr/bin/python2.x."
	ewarn
	ebeep 5
}

src_test() {
	# Tests won't work when cross compiling
	if tc-is-cross-compiler ; then
		elog "Disabling tests due to crosscompiling."
		return
	fi

	# Disabling byte compiling breaks test_import
	python_enable_pyc

	#skip all tests that fail during emerge but pass without emerge:
	#(See bug# 67970)
	local skip_tests="distutils global mimetools minidom mmap posix pyexpat sax strptime subprocess syntax tcl time urllib urllib2 webbrowser xml_etree"

	# test_pow fails on alpha.
	# http://bugs.python.org/issue756093
	[[ ${ARCH} == "alpha" ]] && skip_tests="${skip_tests} pow"

	for test in ${skip_tests} ; do
		mv "${S}"/Lib/test/test_${test}.py "${T}"
	done

	# rerun failed tests in verbose mode (regrtest -w)
	EXTRATESTOPTS="-w" make test || die "make test failed"

	for test in ${skip_tests} ; do
		mv "${T}"/test_${test}.py "${S}"/Lib/test/test_${test}.py
	done

	elog "Portage skipped the following tests which aren't able to run from emerge:"
	for test in ${skip_tests} ; do
		elog "test_${test}.py"
	done

	elog "If you'd like to run them, you may:"
	elog "cd /usr/lib/python${PYVER}/test"
	elog "and run the tests separately."
}
