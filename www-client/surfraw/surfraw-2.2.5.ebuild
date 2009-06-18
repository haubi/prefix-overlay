# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/surfraw/surfraw-2.2.5.ebuild,v 1.4 2009/06/17 20:32:24 fauli Exp $

inherit bash-completion eutils

DESCRIPTION="A fast unix command line interface to WWW"
HOMEPAGE="http://surfraw.alioth.debian.org/"
SRC_URI="http://${PN}.alioth.debian.org/dist/${P}.tar.gz"

SLOT="0"
LICENSE="public-domain"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-2.1.5-gentoo_pkg_tools.patch
	# Man page symlinks shouldn't link to compressed files
	sed -i 's,\.gz,,g' links.IN
}

src_compile() {
	econf \
		--with-elvidir='$(datadir)'/surfraw \
		--disable-opensearch \
		|| die "./configure failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog HACKING NEWS README TODO

	dobashcompletion surfraw-bash-completion
}

pkg_preinst() {
	has_version "=${CATEGORY}/${PN}-1.0.7"
	upgrade_from_1_0_7=$?
}

pkg_postinst() {
	bash-completion_pkg_postinst
	einfo
	einfo "You can get a list of installed elvi by just typing 'surfraw' or"
	einfo "the abbreviated 'sr'."
	einfo
	einfo "You can try some searches, for example:"
	einfo "$ sr ask why is jeeves gay? "
	einfo "$ sr google -results=100 RMS, GNU, which is sinner, which is sin?"
	einfo "$ sr rhyme -method=perfect Julian"
	einfo
	einfo "The system configuration file is /etc/surfraw.conf"
	einfo
	einfo "Users can specify preferences in '~/.surfraw.conf'  e.g."
	einfo "SURFRAW_graphical_browser=mozilla"
	einfo "SURFRAW_text_browser=w3m"
	einfo "SURFRAW_graphical=no"
	einfo
	einfo "surfraw works with any graphical and/or text WWW browser"
	einfo
	if [[ $upgrade_from_1_0_7 = 0 ]] ; then
		ewarn "surfraw usage has changed slightly since version 1.0.7, elvi are now called"
		ewarn "using the 'sr' wrapper script as described above.  If you wish to return to"
		ewarn "the old behaviour you can add /usr/share/surfraw to your \$PATH"
	fi
	# This file was always autogenerated, and is no longer needed.
	if [ -f "${EROOT}"/etc/surfraw_elvi.list ]; then
		rm -f "${EROOT}"/etc/surfraw_elvi.list
	fi
}
