# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/graphviz/graphviz-2.16.1-r3.ebuild,v 1.7 2008/02/17 14:02:07 nixnut Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools multilib python

DESCRIPTION="Open Source Graph Visualization Software"
HOMEPAGE="http://www.graphviz.org/"
SRC_URI="http://www.graphviz.org/pub/graphviz/ARCHIVE/${P}.tar.gz"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc examples gnome gtk jpeg nls perl png python ruby tcl tk"

# Requires ksh
RESTRICT="test"

RDEPEND="
	>=dev-libs/expat-2.0.0
	>=dev-libs/glib-2.11.1
	>=media-libs/fontconfig-2.3.95
	>=media-libs/freetype-2.1.10
	>=media-libs/gd-2.0.28
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.10
	virtual/libiconv
	ruby?	( dev-lang/ruby )
	tcl?	( >=dev-lang/tcl-8.3 )
	tk?		( >=dev-lang/tk-8.3 )
	gtk?	(
		>=x11-libs/gtk+-2
		x11-libs/libXaw
		>=x11-libs/pango-1.12
		>=x11-libs/cairo-1.1.10
		gnome? ( gnome-base/libgnomeui )
	)"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.20
	nls?	( >=sys-devel/gettext-0.14.5 )
	perl?	( dev-lang/swig )
	python?	( dev-lang/swig )
	ruby?	( dev-lang/swig )
	tcl?	( dev-lang/swig )"

# Dependency description / Maintainer-Info:

# Rendering is done via the following plugins (/plugins):
# - core, dot_layout, neato_layout, gd , dot
#   the ones which are always compiled in, depend on zlib, gd
# - gtk
#   Directly depends on gtk-2.
#   gtk-2 depends on pango, cairo and libX11 directly.
# - gdk-pixbuf
#   Disabled, GTK-1 junk.
# - ming
#   Disabled, depends on ming-3.0 which is still p.masked.
# - cairo:
#   Needs pango for text layout, uses cairo methods to draw stuff
# - xlib :
#   needs cairo+pango,
#   can make use of gnomeui and inotify support,
#   needs libXaw for UI

# There can be swig-generated bindings for the following languages (/tclpkg/gv):
# - c-sharp (disabled)
# - scheme (enabled via guile) ... broken on ~x86
# - io (disabled)
# - java (enabled via java) *2
# - lua (enabled via lua)
# - ocaml (enabled via ocaml)
# - perl (enabled via perl) *1
# - php (enabled via php) *2
# - python (enabled via python) *1
# - ruby (enabled via ruby) *1
# - tcl (enabled via tcl)
# *1 = The ${P}-bindings.patch takes care that those bindings are installed to the right location
# *2 = Those bindings don't build because the paths for the headers/libs aren't
#      detected correctly and/or the options passed to swig are wrong (-php instead of -php4/5)

# There are several other tools in /tclpkg:
# gdtclft, tcldot, tclhandle, tclpathplan, tclstubs ; enabled with: --with-tcl
# tkspline, tkstubs ; enabled with: --with-tk

# And the commands (/cmd):
# - dot, dotty, gvpr, lefty, lneato, tools/* :)
# Lefty needs Xaw and X to build

pkg_setup() {
	if use tcl && ! built_with_use dev-lang/swig tcl ; then
		eerror "SWIG has to be built with tcl support."
		die "Missing tcl USE-flag for dev-lang/swig"
	fi

	# bug 181147
	local gdflags
	use png && gdflags="png"
	use jpeg && gdflags="${gdflags} jpeg"
	if [[ -n ${gdflags} ]] && ! built_with_use media-libs/gd ${gdflags} ; then
		local diemsg="Re-emerge media-libs/gd with USE=\"${gdflags}\""
		eerror "${diemsg}"
		die "${diemsg}"
	fi

	# bug 202781
	if use gtk && ! built_with_use x11-libs/cairo svg ; then
		eerror "x11-libs/cairo has to be built with svg support"
		die "emerge x11-libs/cairo with USE=\"svg\""
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-bindings.patch
	epatch "${FILESDIR}"/${P}-gcc43-missing-includes.patch
	epatch "${FILESDIR}"/${P}-python-buildfix.patch
	epatch "${FILESDIR}"/${P}-pango-optional.patch
	epatch "${FILESDIR}"/${P}-tcltk.patch

	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/\.so/.dylib/g' tclpkg/gv/Makefile.am

	# ToDo: Do the same thing for examples and/or
	#       write a patch for a configuration-option
	#       and send it to upstream
	if ! use doc ; then
		find . -iname Makefile.am \
			| xargs sed -i -e '/html_DATA/d' -e '/pdf_DATA/d' || die
	fi

	# This is an old version of libtool
	rm -rf libltdl
	sed -i -e '/libltdl/d' configure.ac || die

	# Update this file from our local libtool which is much newer than the
	# bundled one. This allows MAKEOPTS=-j2 to work on FreeBSD.
	cp "${EPREFIX}"/usr/share/libtool/install-sh config

	# no nls, no gettext, no iconv macro, so disable it
	use nls || { sed -i -e '/^AM_ICONV/d' configure.ac || die; }

	# Nuke the dead symlinks for the bindings
	sed -i -e '/$(pkgluadir)/d' tclpkg/gv/Makefile.am || die

	eautoreconf
}

src_compile() {
	local myconf

	# Core functionality:
	# All of X, cairo-output, gtk need the pango+cairo functionality
	myconf="${myconf}
		$(use_with gtk)
		$(use_with gtk x)
		$(use_with gtk pangocairo)
		--without-ming
		--with-digcola
		--with-ipsepcola
		--with-fontconfig
		--with-freetype
		--with-libgd
		--without-gdk-pixbuf"

	use gtk && myconf="${myconf} $(use_with gnome gnomeui)"

	# Bindings:
	myconf="${myconf}
		--disable-guile
		--disable-java
		--disable-io
		--disable-lua
		--disable-ocaml
		$(use_enable perl)
		--disable-php
		$(use_enable python)
		$(use_enable ruby)
		--disable-sharp
		$(use_enable tcl)
		$(use_enable tk)"

	econf \
		--enable-ltdl \
		${myconf} \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	sed -i -e "s:htmldir:htmlinfodir:g" doc/info/Makefile || die

	emake DESTDIR="${D}" \
		txtdir='${EPREFIX}'/usr/share/doc/${PF} \
		htmldir='${EPREFIX}'/usr/share/doc/${PF}/html \
		htmlinfodir='${EPREFIX}'/usr/share/doc/${PF}/html/info \
		pdfdir='${EPREFIX}'/usr/share/doc/${PF}/pdf \
		pkgconfigdir='${EPREFIX}'/usr/$(get_libdir)/pkgconfig \
		install || die "emake install failed"

	use examples || rm -rf "${ED}/usr/share/graphviz/demo"

	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	# This actually works if --enable-ltdl is passed
	# to configure
	dot -c
	if use python ; then
		python_mod_optimize
	fi
}

pkg_postrm() {
	if use python ; then
		python_mod_cleanup
	fi
}
