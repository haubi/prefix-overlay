# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-1.9.1-r1.ebuild,v 1.2 2009/07/31 15:02:26 arfrever Exp $

EAPI="2"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib java-pkg-opt-2 python autotools prefix

MY_PV="${PV/_beta/b}" # Handle betas
MY_PV="${PV/_/}" # Handle rc1, rc2 etc
MY_PV="${MY_PV/1.9.1/3.5.1}"
MAJ_PV="${PV/_*/}"
PATCH="${PN}-${MAJ_PV}-patches-0.2"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"
SRC_URI="http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${MY_PV}/source/firefox-${MY_PV}-source.tar.bz2
	mirror://gentoo/${PATCH}.tar.bz2"

KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="debug python" # qt-experimental

#	qt-experimental? (
#		x11-libs/qt-gui
#		x11-libs/qt-core )

# nspr-4.8 due to BMO #499144
RDEPEND="java? ( >=virtual/jre-1.4 )
	python? ( >=dev-lang/python-2.3 )

	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.3
	>=dev-libs/nspr-4.8
	kernel_linux? ( media-libs/alsa-lib )
	>=dev-db/sqlite-3.6.7
	>=app-text/hunspell-1.2
	>=media-libs/lcms-1.17

	>=x11-libs/cairo-1.8.8[X]
	x11-libs/pango[X]"

DEPEND="java? ( >=virtual/jdk-1.4 )
	${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/mozilla-${MAJ_PV}"

# Needed by src_compile() and src_install().
# Would do in pkg_setup but that loses the export attribute, they
# become pure shell variables.
export BUILD_OFFICIAL=1
export MOZILLA_OFFICIAL=1

pkg_setup(){
	java-pkg-opt-2_pkg_setup
}

src_prepare() {
	# Apply our patches
	cd "${S}" || die "cd failed"
	EPATCH_SUFFIX="patch" \
	EPATCH_FORCE="yes" \
	epatch "${WORKDIR}"

	epatch "${FILESDIR}"/${PN}-1.9-no_sunstudio.patch # breaks sunstudio
	epatch "${FILESDIR}"/${PN}-1.9-solaris64.patch
	epatch "${FILESDIR}"/${PN}-1.9_beta5-prefix.patch
	eprefixify \
		extensions/java/xpcom/interfaces/org/mozilla/xpcom/Mozilla.java \
		xpcom/build/nsXPCOMPrivate.h \
		xulrunner/installer/Makefile.in \
		xulrunner/app/nsRegisterGREUnix.cpp

	# Same as in config/autoconf.mk.in
	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_PV}/sdk"
	# Gentoo install dirs
	sed -e "s/@PV@/${MAJ_PV}/" -i "${S}/config/autoconf.mk.in" \
		|| die "\${MAJ_PV} sed failed!"

	# Enable gnomebreakpad
	if use debug; then
		sed -i -e 's/GNOME_DISABLE_CRASH_DIALOG=1/GNOME_DISABLE_CRASH_DIALOG=0/g' \
			"${S}/build/unix/run-mozilla.sh"
	fi

	eautoreconf

	cd js/src
	eautoreconf
}

src_configure() {
	declare MOZILLA_FIVE_HOME="/usr/$(get_libdir)/${PN}-1.9"

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	MEXTENSIONS="default"
	if use python; then
		MEXTENSIONS="${MEXTENSIONS},python/xpcom"
	fi

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --enable-application=xulrunner
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate 'broken' --disable-crashreporter
	mozconfig_annotate '' --enable-image-encoder=all
	mozconfig_annotate '' --enable-canvas
	# Bug 60668: Galeon doesn't build without oji enabled, so enable it
	# regardless of java setting.
	mozconfig_annotate '' --enable-oji --enable-mathml
	mozconfig_annotate 'places' --enable-storage --enable-places
	mozconfig_annotate '' --enable-safe-browsing

	# System-wide install specs
	mozconfig_annotate '' --disable-installer
	mozconfig_annotate '' --disable-updater
	mozconfig_annotate '' --disable-strip
	mozconfig_annotate '' --disable-install-strip

	# Use system libraries
	mozconfig_annotate '' --enable-system-cairo
	mozconfig_annotate '' --enable-system-hunspell
	mozconfig_annotate '' --enable-system-sqlite
	mozconfig_annotate '' --with-system-nspr
	mozconfig_annotate '' --with-system-nss
	mozconfig_annotate '' --enable-system-lcms
	mozconfig_annotate '' --with-system-bz2

	# IUSE qt-experimental
#	if use qt-experimental; then
#		ewarn "You are enabling the EXPERIMENTAL qt toolkit"
#		ewarn "Usage is at your own risk"
#		ewarn "Known to be broken. DO NOT file bugs."
#		mozconfig_annotate '' --disable-system-cairo
#		mozconfig_annotate 'qt-experimental' --enable-default-toolkit=cairo-qt
#	else
		mozconfig_annotate 'gtk' --enable-default-toolkit=cairo-gtk2
#	fi

	# Other ff-specific settings
	mozconfig_annotate '' --enable-jsd
	mozconfig_annotate '' --enable-xpctools
	mozconfig_annotate '' --with-default-mozilla-five-home="${EPREFIX}${MOZLIBDIR}"

	#disable java
	if ! use java ; then
		mozconfig_annotate '-java' --disable-javaxpcom
	fi

	# Debug
	if use debug; then
		mozconfig_annotate 'debug' --disable-optimize
		mozconfig_annotate 'debug' --enable-debug=-ggdb
		mozconfig_annotate 'debug' --enable-debug-modules=all
		mozconfig_annotate 'debug' --enable-debugger-info-modules
	fi

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-cxxflags -fno-stack-protector
	fi

	CPPFLAGS="${CPPFLAGS} -DARON_WAS_HERE" \
	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" \
	econf || die

	# It would be great if we could pass these in via CPPFLAGS or CFLAGS prior
	# to econf, but the quotes cause configure to fail.
	sed -i -e \
		's|-DARON_WAS_HERE|-DGENTOO_NSPLUGINS_DIR=\\\"${EPREFIX}/usr/'"$(get_libdir)"'/nsplugins\\\" -DGENTOO_NSBROWSER_PLUGINS_DIR=\\\"${EPREFIX}/usr/'"$(get_libdir)"'/nsbrowser/plugins\\\"|' \
		"${S}"/config/autoconf.mk \
		"${S}"/toolkit/content/buildconfig.html
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${ED}"/usr/bin/xulrunner

	dodir /usr/bin
	dosym "${MOZLIBDIR}/xulrunner" "/usr/bin/xulrunner-${MAJ_PV}"

	# Install python modules
	dosym "${MOZLIBDIR}/python/xpcom" "/$(python_get_sitedir)/xpcom"

	# env.d file for ld search path
	dodir /etc/env.d
	echo "LDPATH=${MOZLIBDIR}" > "${ED}"/etc/env.d/08xulrunner || die "env.d failed"

	# Add vendor
	echo "pref(\"general.useragent.vendor\",\"Gentoo\");" \
		>> "${ED}/${MOZLIBDIR}/defaults/pref/vendor.js"

	if use java ; then
		java-pkg_regjar "${ED}/${MOZLIBDIR}/javaxpcom.jar"
		java-pkg_regjar "${ED}/${SDKDIR}/lib/MozillaGlue.jar"
		java-pkg_regjar "${ED}/${SDKDIR}/lib/MozillaInterfaces.jar"
	fi
}

pkg_postinst() {
	if use python; then
		python_need_rebuild
		python_mod_optimize "${MOZLIBDIR}/python"
	fi

	ewarn "If firefox fails to start with \"failed to load xpcom\", run revdep-rebuild"
	ewarn "If that does not fix the problem, rebuild dev-libs/nss"
	ewarn "Try dev-util/lafilefixer if you get build failures related to .la files"
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup "${MOZLIBDIR}/python"
	fi
}
