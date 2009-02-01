# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.18.4.ebuild,v 1.1 2009/01/13 01:20:56 leio Exp $

EAPI="prefix"

inherit gnome.org libtool eutils flag-o-matic multilib autotools

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc fam hardened selinux xattr"

RDEPEND="virtual/libc
		 virtual/libiconv
		>=sys-devel/gettext-0.11
		 xattr? ( sys-apps/attr )
		 fam? ( virtual/fam )"
DEPEND=">=dev-util/pkgconfig-0.16
		doc?	(
					>=dev-libs/libxslt-1.0
					>=dev-util/gtk-doc-1.8
					~app-text/docbook-xml-dtd-4.1.2
				)
		dev-util/gtk-doc-am"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use ppc64 && use hardened ; then
		replace-flags -O[2-3] -O1
		epatch "${FILESDIR}/glib-2.6.3-testglib-ssp.patch"
	fi

	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	# patch avoids autoreconf necessity
	epatch "${FILESDIR}"/${PN}-2.12.11-solaris-thread.patch

	# Don't fail gio tests when ran without userpriv, upstream bug 552912
	# This is only a temporary workaround, remove as soon as possible
	epatch "${FILESDIR}/${PN}-2.18.1-workaround-gio-test-failure-without-userpriv.patch"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	epatch "${FILESDIR}"/${PN}-2.16.1-interix.patch
	epatch "${FILESDIR}"/${PN}-2.16.3-macos-inline.patch
	epatch "${FILESDIR}"/${PN}-2.18.2-interix.patch
	epatch "${FILESDIR}"/${P}-irix.patch

	# build glib with parity for native win32
	[[ ${CHOST} == *-winnt* ]] && epatch "${FILESDIR}"/${PN}-2.18.3-winnt.patch

	# makes the iconv check more general, needed for winnt, but could
	# be usefull for others too.
	epatch "${FILESDIR}"/${PN}-2.18.3-iconv.patch

	# freebsd: elibtoolize would suffice
	# interix: need recent libtool
	# doing eautoreconf needs gtk-doc.m4, hence dep on dev-util/gtk-doc-am
	AT_M4DIR="m4macros" eautoreconf
}

src_compile() {
	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# non-glibc platforms use GNU libiconv, but configure needs to know about
	# that not to get confused when it finds something outside the prefix too
	if use !elibc_glibc ; then
		myconf="${myconf} --with-libiconv=gnu"
		# add the libdir for libtool, otherwise it'll make love with system
		# installed libiconv
		append-ldflags "-L${EPREFIX}/usr/$(get_libdir)"
	fi

	[[ ${CHOST} == *-interix* ]] && {
		export ac_cv_func_mmap_fixed_mapped=yes
		export ac_cv_func_poll=no
	}

	local mythreads=posix

	[[ ${CHOST} == *-winnt* ]] && mythreads=win32

	# always build static libs, see #153807
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --with-threads=${mythreads} || die "configure failed"

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/lib/charset.alias"

	dodoc AUTHORS ChangeLog* NEWS* README
}
