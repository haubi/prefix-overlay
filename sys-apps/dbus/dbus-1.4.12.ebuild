# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dbus/dbus-1.4.12.ebuild,v 1.6 2011/06/22 20:18:35 ranger Exp $

EAPI=2
inherit autotools eutils multilib flag-o-matic python systemd virtualx linux-info prefix

DESCRIPTION="A message bus system, a simple way for applications to talk to each other"
HOMEPAGE="http://dbus.freedesktop.org/"
SRC_URI="http://dbus.freedesktop.org/releases/dbus/${P}.tar.gz"

LICENSE="|| ( GPL-2 AFL-2.1 )"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc selinux static-libs test X"

RDEPEND="
	X? (
		x11-libs/libX11
		x11-libs/libXt
	)
	selinux? (
		sys-libs/libselinux
		sec-policy/selinux-dbus
	)
	>=dev-libs/expat-1.95.8
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		app-doc/doxygen
		app-text/docbook-xml-dtd:4.1.2
		app-text/xmlto
	)
	test? (
		=dev-lang/python-2*
		>=dev-libs/glib-2.22:2
	)
"

# out of sources build directory
BD=${WORKDIR}/${P}-build
# out of sources build dir for make check
TBD=${WORKDIR}/${P}-tests-build

pkg_setup() {
	enewgroup messagebus
	enewuser messagebus -1 "-1" -1 messagebus

	if use test; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_prepare() {
	# Tests were restricted because of this
	sed -i \
		-e 's/.*bus_dispatch_test.*/printf ("Disabled due to excess noise\\n");/' \
		-e '/"dispatch"/d' \
		bus/test-main.c || die

	epatch "${FILESDIR}"/${PN}-1.4.0-asneeded.patch

	# Doesn't build with PIE support
	if [[ ${CHOST} == *-freebsd7.1 ]]; then
		epatch "${FILESDIR}"/${PN}-1.2.3-freebsd71.patch
	fi

	epatch "${FILESDIR}"/${PN}-1.4.8-interix.patch
	epatch "${FILESDIR}"/${P}-solaris.patch

	if kernel_is lt 2 6 13; then
		ewarn "Warning: Detected old kernel that doesn't support inotify,
		disabling function now (see Gentoo bug 343601)"
		epatch "${FILESDIR}"/no-notify-oldkernel.patch
	fi

	# required for asneeded patch but also for bug 263909, cross-compile so
	# don't remove eautoreconf
	eautoreconf
}

src_configure() {
	local my_conf
	local syssocket="${EPREFIX}"/var/run/dbus/system_bus_socket
	local socketdir="${EPREFIX}"/tmp
	local myconf=""

	if [[ ${CHOST} == *-interix5* ]]; then
		# interix 5.2 socket paths may not be longer than 14
		# chars including the zero. (bug alarm...)
		syssocket="/tmp/dbus_ss"
		socketdir="/tmp"

		myconf="${myconf} --with-test-socket-dir=/tmp"
	fi

	if [[ ${CHOST} != *-interix* ]]; then
		# so we can get backtraces from apps
		append-flags -rdynamic
	else
		# although poll() exists in suacomp and seems to work,
		# the tests crash for unknown reason when enabling it.
		export ac_cv_func_poll=no
	fi

	if [[ ${CHOST} == *-darwin* ]]; then
		myconf="${myconf} --enable-launchd --with-launchd-agent-dir=${EPREFIX}/Library/LaunchAgents"
	fi

	if [[ ${CHOST} == *-solaris* ]] ; then
		# we need more flag trickery as before just to have struct msg_header
		# and f->_dd, bug #378707
		append-flags -D__EXTENSIONS__ -D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED=1
	fi

	# libaudit is *only* used in DBus wrt SELinux support, so disable it, if
	# not on an SELinux profile.
	my_conf="$(use_with X x)
		$(use_enable debug verbose-mode)
		$(use_enable debug asserts)
		$(use_enable kernel_linux inotify)
		$(use_enable kernel_FreeBSD kqueue)
		$(use_enable kernel_Darwin kqueue) \
		$(use_enable kernel_Darwin launchd) \
		$(use_enable selinux)
		$(use_enable selinux libaudit)
		$(use_enable static-libs static)
		--enable-shared
		--with-xml=expat
		--with-system-pid-file=${EPREFIX}/var/run/dbus.pid
		--with-system-socket="${syssocket}"
		--with-session-socket-dir="${socketdir}"
		--with-dbus-user=${PORTAGE_USER:-portage}
		$(systemd_with_unitdir)
		--localstatedir=${EPREFIX}/var
		${myconf}"

	mkdir "${BD}"
	cd "${BD}"
	einfo "Running configure in ${BD}"
	ECONF_SOURCE="${S}" econf ${my_conf} \
		$(use_enable doc doxygen-docs) \
		$(use_enable doc xml-docs)

	if use test; then
		local circular
		if ! has_version dev-libs/dbus-glib; then
			circular="--disable-modular-tests"
			ewarn "Skipping modular tests because dev-libs/dbus-glib is missing"
		fi

		mkdir "${TBD}"
		cd "${TBD}"
		einfo "Running configure in ${TBD}"
		ECONF_SOURCE="${S}" econf \
			${my_conf} \
			$(use_enable test checks) \
			$(use_enable test embedded-tests) \
			$(use_enable test modular-tests) \
			$(use_enable test asserts) \
			${circular}
	fi
}

src_compile() {
	# after the compile, it uses a selinuxfs interface to
	# check if the SELinux policy has the right support
	use selinux && addwrite /selinux/access

	cd "${BD}"
	einfo "Running make in ${BD}"
	emake || die

	if use doc; then
		doxygen || die
	fi

	if use test; then
		cd "${TBD}"
		einfo "Running make in ${TBD}"
		emake || die
	fi
}

src_test() {
	cd "${TBD}"
	DBUS_VERBOSE=1 Xemake -j1 check || die
}

src_install() {
	# initscript
	newinitd "${FILESDIR}"/dbus.init-1.0 dbus || die

	if use X; then
		# dbus X session script (#77504)
		# turns out to only work for GDM (and startx). has been merged into
		# other desktop (kdm and such scripts)
		exeinto /etc/X11/xinit/xinitrc.d/
		doexe "${FILESDIR}"/80-dbus || die
	fi

	# needs to exist for the system socket
	keepdir /var/run/dbus

	# needs to exist for dbus sessions to launch
	keepdir /usr/lib/dbus-1.0/services
	keepdir /usr/share/dbus-1/services
	keepdir /etc/dbus-1/system.d/
	keepdir /etc/dbus-1/session.d/

	dodoc AUTHORS ChangeLog HACKING NEWS README doc/TODO || die

	cd "${BD}"
	# FIXME: split dtd's in dbus-dtd ebuild
	emake DESTDIR="${D}" install || die
	if use doc; then
		dohtml -p api/ doc/api/html/* || die
		cd "${S}"
		dohtml doc/*.html || die
	fi

	# Remove .la files
	find "${ED}" -type f -name '*.la' -exec rm -f {} +
}

pkg_postinst() {
	elog "To start the D-Bus system-wide messagebus by default"
	elog "you should add it to the default runlevel :"
	elog "\`rc-update add dbus default\`"
	elog
	elog "Some applications require a session bus in addition to the system"
	elog "bus. Please see \`man dbus-launch\` for more information."
	elog
	ewarn "You must restart D-Bus \`/etc/init.d/dbus restart\` to run"
	ewarn "the new version of the daemon."
	ewarn "Don't do this while X is running because it will restart your X as well."

	# Move to /etc per #370451 and ensure unique id is generated
	[[ -e ${EROOT}/var/lib/dbus/machine-id ]] && \
		mv -vf "${EROOT}"/var/lib/dbus/machine-id "${EROOT}"/etc/machine-id
	dbus-uuidgen --ensure="${EROOT}"/etc/machine-id

	if [[ ${CHOST} == *-darwin* ]]; then
		local plist="org.freedesktop.dbus-session.plist"
		elog
		elog
		elog "For MacOS/Darwin we now ship launchd support for dbus."
		elog "This enables autolaunch of dbus at session login and makes"
		elog "dbus usable under MacOS/Darwin."
		elog
		elog "The launchd plist file ${plist} has been"
		elog "installed in ${EPREFIX}/Library/LaunchAgents."
		elog "For it to be used, you will have to do all of the following:"
		elog " + cd ~/Library/LaunchAgents"
		elog " + ln -s ${EPREFIX}/Library/LaunchAgents/${plist}"
		#elog "plus either one of the following:"
		elog " + logout and log back in"
		#elog " + issue: launchctl load ./${plist}"
		elog
		elog "If your application needs a proper DBUS_SESSION_BUS_ADDRESS"
		elog "specified and refused to start otherwise, then export the"
		elog "the following to your environment:"
		elog " DBUS_SESSION_BUS_ADDRESS=\"launchd:env=DBUS_LAUNCHD_SESSION_BUS_SOCKET\""
	fi
}
