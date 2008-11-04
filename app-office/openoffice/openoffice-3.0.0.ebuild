# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openoffice/openoffice-3.0.0.ebuild,v 1.17 2008/11/03 11:42:46 suka Exp $

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.9"
EAPI="prefix 1"

inherit autotools check-reqs db-use eutils fdo-mime flag-o-matic java-pkg-opt-2 kde-functions mono multilib toolchain-funcs

IUSE="binfilter cups dbus debug eds gnome gstreamer gtk kde ldap mono nsplugin odk opengl pam templates"

MY_PV="3.0.0.3.5"
PATCHLEVEL="OOO300"
SRC="OOo_${PV}_src"
MST="ooo300-m9"
DEVPATH="http://download.go-oo.org/${PATCHLEVEL}/${MST}"
S="${WORKDIR}/ooo"
S_OLD="${WORKDIR}/ooo-build-${MY_PV}"
CONFFILE="${S}/distro-configs/Gentoo.conf.in"
DESCRIPTION="OpenOffice.org, a full office productivity suite."

SRC_URI="${DEVPATH}-artwork.tar.bz2
	${DEVPATH}-base.tar.bz2
	${DEVPATH}-bootstrap.tar.bz2
	${DEVPATH}-calc.tar.bz2
	${DEVPATH}-components.tar.bz2
	${DEVPATH}-extensions.tar.bz2
	${DEVPATH}-filters.tar.bz2
	${DEVPATH}-impress.tar.bz2
	${DEVPATH}-l10n.tar.bz2
	${DEVPATH}-libs_core.tar.bz2
	${DEVPATH}-libs_extern.tar.bz2
	${DEVPATH}-libs_extern_sys.tar.bz2
	${DEVPATH}-libs_gui.tar.bz2
	${DEVPATH}-postprocess.tar.bz2
	${DEVPATH}-sdk.tar.bz2
	${DEVPATH}-testing.tar.bz2
	${DEVPATH}-ure.tar.bz2
	${DEVPATH}-writer.tar.bz2
	templates? ( http://extensions.services.openoffice.org/files/273/0/Sun_ODF_Template_Pack_en-US.oxt
		http://extensions.services.openoffice.org/files/295/1/Sun_ODF_Template_Pack_de.oxt
		http://extensions.services.openoffice.org/files/299/0/Sun_ODF_Template_Pack_it.oxt
		http://extensions.services.openoffice.org/files/297/0/Sun_ODF_Template_Pack_fr.oxt
		http://extensions.services.openoffice.org/files/301/1/Sun_ODF_Template_Pack_es.oxt )
	http://download.go-oo.org/${PATCHLEVEL}/ooo-build-${MY_PV}.tar.gz
	odk? ( java? ( http://tools.openoffice.org/unowinreg_prebuild/680/unowinreg.dll ) )
	http://download.go-oo.org/SRC680/extras-3.tar.bz2
	http://download.go-oo.org/SRC680/biblio.tar.bz2
	http://download.go-oo.org/SRC680/lp_solve_5.5.0.12_source.tar.gz
	http://download.go-oo.org/DEV300/scsolver.2008-10-07.tar.bz2
	http://download.go-oo.org/SRC680/libwps-0.1.2.tar.gz
	http://download.go-oo.org/SRC680/libwpg-0.1.3.tar.gz"

LANGS1="af ar as_IN be_BY bg bn br bs ca cs cy da de dz el en_GB en_ZA eo es et fa fi fr ga gl gu_IN he hi_IN hr hu it ja km ko ku lt lv mk ml_IN mr_IN nb ne nl nn nr ns or_IN pa_IN pl pt pt_BR ru rw sh sk sl sr ss st sv sw_TZ ta_IN te_IN tg th ti_ER tn tr ts uk ur_IN ve vi xh zh_CN zh_TW zu"
LANGS="${LANGS1} en en_US"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

HOMEPAGE="http://go-oo.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"

COMMON_DEPEND="!app-office/openoffice-bin
	x11-libs/libXaw
	x11-libs/libXinerama
	>=dev-lang/perl-5.0
	dbus? ( >=dev-libs/dbus-glib-0.71 )
	gnome? ( >=x11-libs/gtk+-2.10
		>=gnome-base/gnome-vfs-2.6
		>=gnome-base/gconf-2.0
		>=x11-libs/cairo-1.0.2 )
	gtk? ( >=x11-libs/gtk+-2.10
		>=x11-libs/cairo-1.0.2 )
	eds? ( >=gnome-extra/evolution-data-server-1.2 )
	gstreamer? ( >=media-libs/gstreamer-0.10
			>=media-libs/gst-plugins-base-0.10 )
	kde? ( kde-base/kdelibs:3.5 )
	java? ( >=dev-java/bsh-2.0_beta4
		>=dev-db/hsqldb-1.8.0.9 )
	mono? ( >=dev-lang/mono-1.2.3.1 )
	opengl? ( virtual/opengl
		virtual/glu )
	>=net-misc/neon-0.24.7
	>=dev-libs/openssl-0.9.8g
	>=x11-libs/startup-notification-0.5
	>=media-libs/freetype-2.1.10-r2
	>=media-libs/fontconfig-2.3.0
	cups? ( net-print/cups )
	media-libs/jpeg
	media-libs/libpng
	app-arch/zip
	app-arch/unzip
	>=app-text/hunspell-1.1.4-r1
	dev-libs/expat
	>=dev-libs/icu-3.8
	>=sys-libs/db-4.3
	>=app-text/libwpd-0.8.8
	>=media-libs/vigra-1.4
	>=app-text/poppler-0.8.0
	linguas_ja? ( >=media-fonts/kochi-substitute-20030809-r3 )
	linguas_zh_CN? ( >=media-fonts/arphicfonts-0.1-r2 )
	linguas_zh_TW? ( >=media-fonts/arphicfonts-0.1-r2 )"

RDEPEND="java? ( >=virtual/jre-1.5 )
	${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	x11-libs/libXrender
	x11-libs/libXtst
	x11-proto/printproto
	x11-proto/xextproto
	x11-proto/xproto
	x11-proto/xineramaproto
	>=sys-apps/findutils-4.1.20-r1
	dev-perl/Archive-Zip
	dev-perl/Compress-Zlib
	>=dev-perl/Compress-Raw-Zlib-2.002
	dev-perl/IO-Compress-Base
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-libs/boost-1.33.1
	sys-devel/flex
	sys-devel/bison
	dev-libs/libxslt
	>=dev-libs/libxml2-2.0
	>=dev-util/gperf-3
	>=net-misc/curl-7.12
	sys-libs/zlib
	sys-apps/coreutils
	media-gfx/imagemagick
	pam? ( sys-libs/pam )
	!dev-util/dmake
	>=dev-lang/python-2.3.4
	nsplugin? ( || ( net-libs/xulrunner:1.8 net-libs/xulrunner:1.9 =www-client/seamonkey-1* )
		>=dev-libs/nspr-4.6.6
		>=dev-libs/nss-3.11-r1 )
	java? ( || ( =virtual/jdk-1.6* =virtual/jdk-1.5* )
		>=dev-java/ant-core-1.7 )
	ldap? ( net-nds/openldap )"

PROVIDE="virtual/ooo"

pkg_setup() {

	ewarn
	ewarn " It is important to note that OpenOffice.org is a very fragile  "
	ewarn " build when it comes to CFLAGS.  A number of flags have already "
	ewarn " been filtered out.  If you experience difficulty merging this  "
	ewarn " package and use agressive CFLAGS, lower the CFLAGS and try to  "
	ewarn " merge again. Also note that building OOo takes a lot of time and "
	ewarn " hardware ressources: 4-6 GB free diskspace and 256 MB RAM are "
	ewarn " the minimum requirements. If you have less, use openoffice-bin "
	ewarn " instead. "
	ewarn
	ewarn " Also if you experience a build break, please make sure to retry "
	ewarn " with MAKEOPTS="-j1" before filing a bug. "
	ewarn

	# Check if we have enough RAM and free diskspace to build this beast
	CHECKREQS_MEMORY="512"
	use debug && CHECKREQS_DISK_BUILD="8192" || CHECKREQS_DISK_BUILD="5120"
	check_reqs

	strip-linguas ${LANGS}

	if [[ -z "${LINGUAS}" ]]; then
		export LINGUAS_OOO="en-US"
		ewarn
		ewarn " To get a localized build, set the according LINGUAS variable(s). "
		ewarn
	else
		export LINGUAS_OOO=`echo ${LINGUAS} | \
			sed -e 's/\ben\b/en_US/g' -e 's/_/-/g'`
	fi

	if use !java; then
		ewarn " You are building with java-support disabled, this results in some "
		ewarn " of the OpenOffice.org functionality being disabled. "
		ewarn " If something you need does not work for you, rebuild with "
		ewarn " java in your USE-flags. "
		ewarn
	fi

	if use !gtk && use !gnome; then
		ewarn " If you want the OpenOffice.org systray quickstarter to work "
		ewarn " activate either the 'gtk' or 'gnome' use flags. "
		ewarn
	fi

	if is-flagq -ffast-math ; then
		eerror " You are using -ffast-math, which is known to cause problems. "
		eerror " Please remove it from your CFLAGS, using this globally causes "
		eerror " all sorts of problems. "
		eerror " After that you will also have to - at least - rebuild python otherwise "
		eerror " the openoffice build will break. "
		die
	fi

	if use pam; then
		if ! built_with_use sys-apps/shadow pam; then
			eerror " shadow needs to be built with pam-support. "
			eerror " rebuild it accordingly or remove the pam use-flag "
			die
		fi
	fi

	if use kde; then
		ewarn " Please note that this version of OpenOffice.org will NOT build "
		ewarn " if you have kde-base/kdelibs or kde-base/kdepimlibs 4.1.x installed "
		ewarn " without kdeprefix"
		ewarn
		ewarn " Until this is resolved, either disable the kde-use-flag or "
		ewarn " rebuild KDE with USE='kdeprefix'. "
		ewarn

		if has_version kde-base/kdelibs:4.1; then
			built_with_use kde-base/kdelibs:4.1 kdeprefix || die "rebuild kde-4.1 with USE='kdeprefix'"
		fi

		if has_version kde-base/kdepimlibs:4.1; then
			built_with_use kde-base/kdepimlibs:4.1 kdeprefix || die "rebuild kde-4.1 with USE='kdeprefix'"
		fi
	fi

	if use nsplugin; then
		if pkg-config --exists libxul; then
			BRWS="libxul"
		elif pkg-config --exists xulrunner-xpcom; then
			BRWS="xulrunner"
		elif pkg-config --exists seamonkey-xpcom; then
			BRWS="seamonkey"
		else
			die "USE flag [nsplugin] set but no installed xulrunner or seamonkey found!"
		fi
	fi

	# Check python
	if ! built_with_use dev-lang/python threads
	then
	    eerror "Python needs to be built with threads."
	    die
	fi

	java-pkg-opt-2_pkg_setup

	# sys-libs/db version used
	local db_ver="$(db_findver '>=sys-libs/db-4.3')"

}

src_unpack() {

	unpack ooo-build-${MY_PV}.tar.gz

	# Prefix patch
	epatch "${FILESDIR}/ooo-build-2.4.1.6-prefix.patch"

	# Hackish workaround for overlong path problem, see bug #130837
	mv "${S_OLD}" "${S}" || die

	#Some fixes for our patchset
	cd "${S}"
	epatch "${FILESDIR}/gentoo-${PV}.diff"
	epatch "${FILESDIR}/ooo-env_log.diff"
	cp -f "${FILESDIR}/nojavanostax.diff" "${S}/patches/dev300" || die
	cp -f "${FILESDIR}/hunspell-one-dir-nocrash.diff" "${S}/patches/dev300" || die

	#Use flag checks
	if use java ; then
		echo "--with-ant-home=${ANT_HOME}" >> ${CONFFILE}
		echo "--with-jdk-home=$(java-config --jdk-home 2>/dev/null)" >> ${CONFFILE}
		echo "--with-java-target-version=$(java-pkg_get-target)" >> ${CONFFILE}
		echo "--with-system-beanshell" >> ${CONFFILE}
		echo "--with-system-hsqldb" >> ${CONFFILE}
		echo "--with-beanshell-jar=$(java-pkg_getjar bsh bsh.jar)" >> ${CONFFILE}
		echo "--with-hsqldb-jar=$(java-pkg_getjar hsqldb hsqldb.jar)" >> ${CONFFILE}
	fi

	if use nsplugin ; then
		echo "--enable-mozilla" >> ${CONFFILE}
		echo "--with-system-mozilla=${BRWS}" >> ${CONFFILE}
	else
		echo "--disable-mozilla" >> ${CONFFILE}
		echo "--without-system-mozilla" >> ${CONFFILE}
	fi

	echo "`use_enable binfilter`" >> ${CONFFILE}
	echo "`use_enable cups`" >> ${CONFFILE}
	echo "`use_enable dbus`" >> ${CONFFILE}
	echo "`use_enable eds evolution2`" >> ${CONFFILE}
	echo "`use_enable gnome gnome-vfs`" >> ${CONFFILE}
	echo "`use_enable gnome lockdown`" >> ${CONFFILE}
	echo "`use_enable gstreamer`" >> ${CONFFILE}
	echo "`use_enable gtk systray`" >> ${CONFFILE}
	echo "`use_enable ldap`" >> ${CONFFILE}
	echo "`use_enable opengl`" >> ${CONFFILE}
	echo "`use_with ldap openldap`" >> ${CONFFILE}
	echo "`use_enable debug crashdump`" >> ${CONFFILE}
	echo "`use_enable debug strip-solver`" >> ${CONFFILE}

	# Extension stuff
	echo "--with-extension-integration" >> ${CONFFILE}
	echo "--enable-minimizer" >> ${CONFFILE}
	echo "--enable-pdfimport" >> ${CONFFILE}
	echo "--enable-presenter-console" >> ${CONFFILE}

	# Use splash screen without Sun logo
	echo "--with-intro-bitmaps=\\\"${S}/build/${MST}/ooo_custom_images/nologo/introabout/intro.bmp\\\"" >> ${CONFFILE}

	eautoreconf

}

src_compile() {

	# Use multiprocessing by default now, it gets tested by upstream
	export JOBS=`echo "${MAKEOPTS}" | sed -e "s/.*-j\([0-9]\+\).*/\1/"`

	# Compile problems with these ...
	filter-flags "-funroll-loops"
	filter-flags "-fprefetch-loop-arrays"
	filter-flags "-fno-default-inline"
	filter-flags "-fstack-protector"
	filter-flags "-fstack-protector-all"
	filter-flags "-ftracer"
	filter-flags "-fforce-addr"

	filter-flags "-O[s2-9]"

	if [[ $(gcc-major-version) -lt 4 ]]; then
		replace-flags "-fomit-frame-pointer" "-momit-leaf-frame-pointer"
	fi

	# Build with NVidia cards breaks otherwise
	use opengl && append-flags "-DGL_GLEXT_PROTOTYPES"

	# Now for our optimization flags ...
	export ARCH_FLAGS="${CXXFLAGS}"
	use debug || export LINKFLAGSOPTIMIZE="${LDFLAGS}"

	# Make sure gnome-users get gtk-support
	local GTKFLAG="--disable-gtk --disable-cairo --without-system-cairo"
	( use gtk || use gnome ) && GTKFLAG="--enable-gtk --enable-cairo --with-system-cairo"

	cd "${S}"
	./configure \
		--prefix="${EPREFIX}"/usr \
		--with-distro="Gentoo" \
		--with-arch="${ARCH}" \
		--with-srcdir="${DISTDIR}" \
		--with-lang="${LINGUAS_OOO}" \
		--with-num-cpus="${JOBS}" \
		--without-binsuffix \
		--with-installed-ooo-dirname="openoffice" \
		--with-tag="${MST}" \
		${GTKFLAG} \
		`use_enable mono` \
		`use_enable kde` \
		`use_enable !debug strip` \
		`use_enable odk` \
		`use_enable pam` \
		`use_with java` \
		`use_with templates sun-templates` \
		--disable-access \
		--disable-post-install-scripts \
		--enable-extensions \
		--with-system-libwpd \
		--mandir="${EPREFIX}"/usr/share/man \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		|| die "Configuration failed!"

	einfo "Building OpenOffice.org..."
	use kde && set-kdedir 3
	make || die "Build failed"

}

src_install() {

	export PYTHONPATH=""

	einfo "Preparing Installation"
	make DESTDIR="${D}" install || die "Installation failed!"

	# Fix the permissions for security reasons
	chown -R root:0 "${ED}"

	# record java libraries
	use java && java-pkg_regjar "${ED}"/usr/$(get_libdir)/openoffice/basis3.0/program/classes/*.jar

}

pkg_postinst() {

	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

# does this make sense for Prefix?
	[[ -x ${EPREFIX}/sbin/chpax ]] && [[ -e ${EPREFIX}/usr/$(get_libdir)/openoffice/basis3.0/program/soffice.bin ]] && chpax -zm ${EPREFIX}/usr/$(get_libdir)/openoffice/basis3.0/program/soffice.bin

	# Add available & useful jars to openoffice classpath
	use java && ${EPREFIX}/usr/$(get_libdir)/openoffice/basis3.0/program/java-set-classpath $(java-config --classpath=jdbc-mysql 2>/dev/null) >/dev/null

	elog
	elog " Spell checking is provided through our own myspell-ebuilds, "
	elog " if you want to use it, please install the correct myspell package "
	elog " according to your language needs. "
	elog

	elog " Some aditional functionality can be installed via Extension Manager: "
	elog " *) PDF Import "
	elog " *) Presentation Console "
	elog " *) Presentation Minimizer "
	elog
	elog " Please use the packages provided in "
	elog " /usr/$(get_libdir)/openoffice/share/extension/install/ "
	elog " instead of those from the SUN extension site. "
	elog

}
