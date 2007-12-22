# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cvs/cvs-1.12.13.1.ebuild,v 1.4 2007/12/07 01:55:55 mr_bones_ Exp $

EAPI="prefix"

inherit eutils pam versionator

DESCRIPTION="Concurrent Versions System - source code revision control tools"
HOMEPAGE="http://www.nongnu.org/cvs/"

DOC_PV="$(get_version_component_range 1-3)"
FEAT_URIBASE="mirror://gnu/non-gnu/cvs/source/feature/${PV}/"
DOC_URIBASE="mirror://gnu/non-gnu/cvs/source/feature/${DOC_PV}/"
SNAP_URIBASE="mirror://gnu/non-gnu/cvs/source/nightly-snapshots/feature/"
SRC_URI="
	${FEAT_URIBASE}/${P}.tar.bz2
	${SNAP_URIBASE}/${P}.tar.bz2
	doc? (
		${DOC_URIBASE}/cederqvist-${DOC_PV}.html.tar.bz2
		${DOC_URIBASE}/cederqvist-${DOC_PV}.pdf
		${DOC_URIBASE}/cederqvist-${DOC_PV}.ps
		)"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~x86 ~x86-macos"

IUSE="crypt doc emacs kerberos nls pam server"

DEPEND=">=sys-libs/zlib-1.1.4
		kerberos? ( virtual/krb5 )
		pam? ( virtual/pam )"

src_unpack() {
	unpack ${P}.tar.bz2
	use doc && unpack cederqvist-${DOC_PV}.html.tar.bz2

	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.12.12-cvsbug-tmpfix.patch
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.12.12-install-sh.patch
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.12.13.1-block-requests.patch
	# Applied by upstream:
	#EPATCH_OPTS="-p1 -d ${S}" epatch ${FILESDIR}/${PN}-1.12.13-openat.patch
	#EPATCH_OPTS="-p0 -d ${S}" epatch ${FILESDIR}/${PN}-1.12.13-zlib.patch

	cd "${S}"
	# this testcase was not updated
	#sed -i.orig -e '/unrecognized keyword.*BogusOption/s,98,73,g' \
	#  ${S}/src/sanity.sh
	# this one fails when the testpath path contains '.'
	sed -i.orig \
		-e '/newfile config3/s,a-z,a-z.,g' \
		"${S}"/src/sanity.sh

	elog "If you want any CVS server functionality, you MUST emerge with USE=server!"
}

src_compile() {
	local myconf
	# the tests need the server and proxy
	if has test $FEATURES; then
		use server || \
		ewarn "The server and proxy code are enabled as they are required for tests."
		myconf="--enable-server --enable-proxy"
	fi
	econf \
		--with-external-zlib \
		--with-tmpdir=/tmp \
		$(use_enable crypt encryption) \
		$(use_with kerberos gssapi) \
		$(use_enable nls) \
		$(use_enable pam) \
		$(use_enable server) \
		$(use_enable server proxy) \
		${myconf} \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die

	if use server; then
	  insinto /etc/xinetd.d
	  newins "${FILESDIR}"/cvspserver.xinetd.d cvspserver || die "newins failed"
	fi

	dodoc BUGS ChangeLog* DEVEL* FAQ HACKING \
		MINOR* NEWS PROJECTS README* TESTS TODO

	if use emacs; then
		insinto /usr/share/emacs/site-lisp
		doins cvs-format.el || die "doins failed"
	fi

	use server && newdoc "${FILESDIR}"/${PN}-1.12.12-cvs-custom.c cvs-custom.c

	if use doc; then
		dodoc "${DISTDIR}"/cederqvist-${DOC_PV}.pdf
		dodoc "${DISTDIR}"/cederqvist-${DOC_PV}.ps
		dohtml -r "${WORKDIR}"/cederqvist-${DOC_PV}.html/
		cd "${ED}"/usr/share/doc/${PF}/html/
		ln -s cvs.html index.html
	fi

	newpamd "${FILESDIR}"/cvs.pam-include-1.12.12 cvs
}

_run_one_test() {
	mode="$1" ; shift
	einfo "Starting ${mode} test"
	cd "${S}"/src
	export TESTDIR="${T}/tests-${mode}"
	rm -rf "$TESTDIR" # Clean up from any previous test passes
	mkdir -p "$TESTDIR"
	emake -j1 ${mode}check || die "Some ${mode} test failed."
	mv -f check.log check.log-${mode}
	einfo "${mode} test completed successfully, log is check.log-${mode}"
}

src_test() {
	einfo "If you want to see realtime status, or check out a failure,"
	einfo "please look at ${S}/src/check.log*"

	if [ "$TEST_REMOTE_AND_PROXY" == "1" ]; then
		einfo "local, remote, and proxy tests enabled."
	else
		einfo "Only testing local mode. Please see ebuild for other modes."
	fi

	# we only do the local tests by default
	_run_one_test local

	# if you want to test the remote and proxy modes, things get a little bit
	# complicated. You need to set up a SSH config file at ~portage/.ssh/config
	# that allows the portage user to login without any authentication, and also
	# set up the ~portage/.ssh/known_hosts file for your machine.
	# We do not do this by default, as it is unsafe from a security point of
	# view, and requires root level ssh changes.
	# Note that this also requires having a real shell for the portage user, so make
	# sure that su -c 'ssh portage@mybox' portage works first!
	# (It uses the local ip, not loopback)
	if [ "$TEST_REMOTE_AND_PROXY" == "1" ]; then
		_run_one_test remote
		_run_one_test proxy
	fi
}
