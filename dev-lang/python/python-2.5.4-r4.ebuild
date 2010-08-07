# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/python/python-2.5.4-r4.ebuild,v 1.23 2010/07/10 13:06:28 arfrever Exp $

EAPI="1"

inherit autotools eutils flag-o-matic multilib pax-utils python toolchain-funcs

MY_P="Python-${PV}"

PATCHSET_REVISION="3"

DESCRIPTION="Python is an interpreted, interactive, object-oriented programming language."
HOMEPAGE="http://www.python.org/"
SRC_URI="http://www.python.org/ftp/python/${PV}/${MY_P}.tar.bz2
	mirror://gentoo/python-gentoo-patches-${PV}$([[ "${PATCHSET_REVISION}" != "0" ]] && echo "-r${PATCHSET_REVISION}").tar.bz2"

LICENSE="PSF-2.2"
SLOT="2.5"
PYTHON_ABI="${SLOT}"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="-berkdb build doc elibc_uclibc examples gdbm ipv6 +ncurses +readline sqlite +ssl +threads tk +wide-unicode wininst +xml"

# NOTE: dev-python/{elementtree,celementtree,pysqlite}
#       do not conflict with the ones in python proper. - liquidx

RDEPEND=">=app-admin/eselect-python-20091230
		>=sys-libs/zlib-1.1.3
		virtual/libffi
		virtual/libintl
		!build? (
			berkdb? ( || (
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
		dev-util/pkgconfig"
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

	if built_with_use sys-devel/gcc libffi; then
		die "Reinstall sys-devel/gcc with \"libffi\" USE flag disabled"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Ensure that internal copies of expat, libffi and zlib are not used.
	rm -fr Modules/expat
	rm -fr Modules/_ctypes/libffi*
	rm -fr Modules/zlib

	if tc-is-cross-compiler; then
		epatch "${FILESDIR}/python-2.5-cross-printf.patch"
	else
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
	epatch "${FILESDIR}"/${PN}-2.5.4-disable-sunaudiodev-bsddb185.patch
	epatch "${FILESDIR}"/${PN}-2.6.2-solaris64-crypt.patch
	epatch "${FILESDIR}"/${PN}-2.6.4-netpacket-solaris.patch

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
	# Disable extraneous modules with extra dependencies.
	if use build; then
		export PYTHON_DISABLE_MODULES="dbm _bsddb gdbm _curses _curses_panel readline _sqlite3 _tkinter pyexpat"
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
		use xml      || disable+=" pyexpat"
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

	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	[[ ${CHOST} == *-mint* ]] && export ac_cv_func_poll=no

	if [[ "$(gcc-major-version)" -ge 4 ]]; then
		append-flags -fwrapv
	fi

	export OPT="${CFLAGS}"

	filter-flags -malign-double

	[[ "${ARCH}" == "alpha" ]] && append-flags -fPIC

	# https://bugs.gentoo.org/show_bug.cgi?id=50309
	if is-flagq -O3; then
		is-flagq -fstack-protector-all && replace-flags -O3 -O2
		use hardened && replace-flags -O3 -O2
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

	# Set LDFLAGS so we link modules with -lpython2.5 correctly.
	# Needed on FreeBSD unless Python 2.5 is already installed.
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
		$(use_enable ipv6) \
		$(use_with threads) \
		$(use wide-unicode && echo "--enable-unicode=ucs4" || echo "--enable-unicode=ucs2") \
		--infodir='${prefix}/share/info' \
		--mandir='${prefix}/share/man' \
		--with-libc="" \
		--with-system-ffi
}

src_compile() {
	src_configure
	emake || die "emake failed"
	if [[ ${CHOST} == *-darwin* ]] ; then
		# create libpython on Darwin
		emake libpython2.5.dylib || die
	fi
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
	local skip_tests="distutils global mimetools minidom mmap posix pyexpat sax strptime subprocess syntax tcl time urllib urllib2 xml_etree"

	# test_ctypes fails with PAX kernel (bug #234498).
	host-is-pax && skip_tests+=" ctypes"

	for test in ${skip_tests}; do
		mv "${S}/Lib/test/test_${test}.py" "${T}"
	done

	# Redirect stdin from /dev/tty as a workaround for bug #248081.
	# Rerun failed tests in verbose mode (regrtest -w).
	EXTRATESTOPTS="-w" emake test < /dev/tty
	local result="$?"

	for test in ${skip_tests}; do
		mv "${T}/test_${test}.py" "${S}/Lib/test/test_${test}.py"
	done

	elog "The following tests have been skipped:"
	for test in ${skip_tests}; do
		elog "test_${test}.py"
	done

	elog "If you would like to run them, you may:"
	elog "cd '${EPREFIX}$(python_get_libdir)/test'"
	elog "and run the tests separately."

	python_disable_pyc

	if [[ "${result}" -ne 0 ]]; then
		die "emake test failed"
	fi
}

src_install() {
	[[ -z "${ED}" ]] && use !prefix && ED="${D%/}${EPREFIX}/"

	[[ ${CHOST} == *-mint* ]] && keepdir /usr/lib/python${PYVER}/lib-dynload/
	emake DESTDIR="${D}" altinstall maninstall || die "emake altinstall maninstall failed"
	python_clean_installation_image -q

	mv "${ED}usr/bin/python${SLOT}-config" "${ED}usr/bin/python-config-${SLOT}"

	# Fix collisions between different slots of Python.
	mv "${ED}usr/bin/pydoc" "${ED}usr/bin/pydoc${SLOT}"
	mv "${ED}usr/bin/idle" "${ED}usr/bin/idle${SLOT}"
	mv "${ED}usr/share/man/man1/python.1" "${ED}usr/share/man/man1/python${SLOT}.1"
	rm -f "${ED}usr/bin/smtpd.py"

	# Fix the OPT variable so that it doesn't have any flags listed in it.
	# Prevents the problem with compiling things with conflicting flags later.
	sed -e "s:^OPT=.*:OPT=\t\t-DNDEBUG:" -i "${ED}$(python_get_libdir)/config/Makefile"

	if use build ; then
		rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{bsddb,idlelib,lib-tk,sqlite3,test}
	else
		use elibc_uclibc && rm -fr "${ED}$(python_get_libdir)/"{bsddb/test,test}
		use berkdb || rm -fr "${ED}$(python_get_libdir)/"{bsddb,test/test_bsddb*}
		use sqlite || rm -fr "${ED}$(python_get_libdir)/"{sqlite3,test/test_sqlite*}
		use tk || rm -fr "${ED}usr/bin/idle${SLOT}" "${ED}$(python_get_libdir)/"{idlelib,lib-tk}
	fi

	prep_ml_includes $(python_get_includedir)

	dodoc Misc/{ACKS,HISTORY,NEWS} || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r "${S}/Tools" || die "doins failed"
	fi

	newinitd "${FILESDIR}/pydoc.init" pydoc-${SLOT} || die "newinitd failed"
	newconfd "${FILESDIR}/pydoc.conf" pydoc-${SLOT} || die "newconfd failed"
}

pkg_preinst() {
	if has_version "<${CATEGORY}/${PN}-${SLOT}" && ! has_version "${CATEGORY}/${PN}:2.5" && ! has_version "${CATEGORY}/${PN}:2.6" && ! has_version "${CATEGORY}/${PN}:2.7"; then
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
