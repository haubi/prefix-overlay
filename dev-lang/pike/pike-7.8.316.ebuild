# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/pike/pike-7.8.316.ebuild,v 1.2 2009/09/09 21:21:35 mr_bones_ Exp $

EAPI="2"
DESCRIPTION="Pike programming language and runtime"
HOMEPAGE="http://pike.ida.liu.se/"
SRC_URI="http://pike.ida.liu.se/pub/pike/all/${PV}/Pike-v${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2.1 MPL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="bzip2 debug doc fftw gdbm glut gnome gtk hardened java jpeg kerberos mysql odbc opengl pcre pdf scanner sdl sqlite svg test tiff truetype zlib"

DEPEND="<dev-libs/nettle-2
	dev-libs/gmp
	media-libs/giflib
	bzip2? ( app-arch/bzip2 )
	fftw? ( sci-libs/fftw )
	gdbm? ( sys-libs/gdbm )
	gtk? ( =x11-libs/gtk+-1.2* >x11-libs/gtk+-2 )
	gtk? ( gnome? ( gnome-base/libgnome gnome-base/libgnomeui gnome-base/gnome-applets gnome-base/libglade ) )
	gtk? ( opengl? ( x11-libs/gtkglarea ) )
	java? ( virtual/jdk virtual/libffi )
	jpeg? ( media-libs/jpeg )
	kerberos? ( virtual/krb5 net-libs/libgssglue )
	mysql? ( virtual/mysql )
	odbc? ( dev-db/libiodbc )
	opengl? ( virtual/opengl glut? ( virtual/glut ) )
	pcre? ( dev-libs/libpcre )
	pdf? ( media-libs/pdflib )
	!x86-fbsd? ( scanner? ( media-gfx/sane-backends ) )
	sdl? ( media-libs/libsdl media-libs/sdl-mixer )
	sqlite? ( dev-db/sqlite )
	svg? ( gnome-base/librsvg )
	test? ( sys-devel/m4 )
	tiff? ( media-libs/tiff )
	truetype? ( >media-libs/freetype-2 )
	zlib? ( sys-libs/zlib )"
RDEPEND=""

S=${WORKDIR}/Pike-v${PV}

src_compile() {
	local myconf=""
	# ffmpeg is broken atm #110136
	myconf="${myconf} --without-_Ffmpeg"
	# on hardened, disable runtime-generated code
	# otherwise let configure work it out for itself
	use hardened && myconf="${myconf} --without-machine-code"

	make \
		CONFIGUREARGS=" \
			--prefix=/usr \
			--disable-make_conf \
			--disable-noopty-retry \
			--without-cdebug \
			--without-bundles \
			--without-copt \
			--without-ssleay \
			--with-crypt \
			--with-gif \
			--with-gmp \
			--with-bignums \
			$(use_with bzip2 Bz2) \
			$(use_with debug rtldebug) \
			$(use_with fftw) \
			$(use_with gdbm) \
			$(use_with java Java) \
			$(use_with jpeg jpeglib) \
			$(use_with kerberos Kerberos) \
			$(use_with kerberos gssapi) \
			$(use_with mysql) \
			$(use_with odbc Odbc) \
			$(use_with opengl GL) \
			$(use opengl && use_with glut GLUT) \
			$(use opengl || use_with opengl GLUT) \
			$(use_with pcre _Regexp_PCRE) \
			$(use_with pdf libpdf) \
			$(use_with scanner sane) \
			$(use_with sdl SDL) \
			$(use_with sdl SDL_mixer) \
			$(use_with svg) \
			$(use_with tiff tifflib) \
			$(use_with truetype freetype) \
			$(use_with zlib) \
			${myconf} \
			" || die "compilation failed"

	if use doc; then
		PATH="${S}/bin:${PATH}" make doc || die "doc failed"
	fi
}

src_install() {
	# do not remove modules to avoid sandbox violation.
	# The sandbox really ought to allow deletion of files
	# that belong to previous installs of the ebuild, or
	# even better: hide them.
	sed -i s/rm\(mod\+\"\.o\"\)\;/break\;/ "${S}"/bin/install.pike || die "Failed to modify install.pike (1)"
	sed -i 's/\(Array.map *( *files_to_delete *- *files_to_not_delete, *rm *);\)/; \/\/ \1/' "${S}"/bin/install.pike || die "Failed to modify install.pike (2)"
	if use doc ; then
		make INSTALLARGS="--traditional" buildroot="${D}" install || die
		einfo "Installing 60MB of docs, this could take some time ..."
		dohtml -r "${S}"/refdoc/traditional_manual "${S}"/refdoc/modref
	else
		make INSTALLARGS="--traditional" buildroot="${D}" install_nodoc || die
	fi
	# Installation is a bit broken.. remove the doc sources.
	rm -rf "${ED}/usr/doc"
	# Install the man pages in the proper location.
	rm -rf "${ED}/usr/man" && doman "${S}/man/pike.1"
}
