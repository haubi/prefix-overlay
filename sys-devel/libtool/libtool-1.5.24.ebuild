# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/libtool-1.5.24.ebuild,v 1.13 2007/10/06 05:05:26 tgall Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1.5"
KEYWORDS="~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="vanilla"

RDEPEND="sys-devel/gnuconfig
	>=sys-devel/autoconf-2.60
	>=sys-devel/automake-1.10"
DEPEND="${RDEPEND}
	sys-apps/help2man"

gen_ltmain_sh() {
	local date=
	local PACKAGE=
	local VERSION=

	rm -f ltmain.shT
	date=`./mkstamp < ./ChangeLog` && \
	eval `egrep '^[[:space:]]*PACKAGE.*=' configure` && \
	eval `egrep '^[[:space:]]*VERSION.*=' configure` && \
	sed -e "s/@PACKAGE@/${PACKAGE}/" -e "s/@VERSION@/${VERSION}/" \
		-e "s%@TIMESTAMP@%$date%" ./ltmain.in > ltmain.shT || return 1

	mv -f ltmain.shT ltmain.sh || {
		(rm -f ltmain.sh && cp ltmain.shT ltmain.sh && rm -f ltmain.shT)
		return 1
	}

	return 0
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	use vanilla && return 0

	# Make sure non of the patches touch ltmain.sh, but rather ltmain.in
	rm -f ltmain.sh*

	epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
	epatch "${FILESDIR}"/1.5.10/${PN}-1.5.10-portage.patch
	epatch "${FILESDIR}"/1.5.10/libtool-1.5.10-locking.patch #40992

	# Note: The following patches should be dropped with libtool-2+
	epatch "${FILESDIR}"/1.5.20/${PN}-1.5.20-version-checking.patch #73140
	sed -i "s:@_LT_VERSION@:${PV}:" libtool.m4 || die "sed libtool.m4"
	epatch "${FILESDIR}"/1.5.6/libtool-1.5-filter-host-tags.patch
	epatch "${FILESDIR}"/1.5.20/libtool-1.5.20-override-LD_LIBRARY_PATH.patch
	epatch "${FILESDIR}"/${PN}-1.5.23b-aixrtl.patch

	ebegin "Generating ltmain.sh"
	gen_ltmain_sh || die "Failed to generate ltmain.sh!"
	eend 0

	# Now let's run all our autotool stuff so that files we patch
	# below don't get regenerated on us later
	cp libtool.m4 acinclude.m4
	local d p
	for d in . libltdl ; do
		ebegin "Running autotools in '${d}'"
		cd "${S}"/${d}
		touch acinclude.m4
		for p in aclocal "automake -c -a" autoconf ; do
			${p} || die "${p}"
		done
		eend 0
	done
	cd "${S}"

	epunt_cxx
}

src_compile() {
	local myconf
	# usr/bin/libtool is provided by odcctools
	[[ ${CHOST} == *-darwin* ]] && myconf="--program-prefix=g"
	econf ${myconf} || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local x
	for x in libtool libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${ED}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf ../gnuconfig/$(basename "${x}") "${x}"
	done
	cd "${ED}"/usr/share/libtool/libltdl
	for x in config.guess config.sub ; do
		rm -f ${x} ; ln -sfn ../${x} ${x}
	done
}
