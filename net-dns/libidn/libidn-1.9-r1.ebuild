# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-dns/libidn/libidn-1.9-r1.ebuild,v 1.1 2008/09/03 13:29:17 ulm Exp $

EAPI="prefix"

inherit java-pkg-opt-2 mono elisp-common

DESCRIPTION="Internationalized Domain Names (IDN) implementation"
HOMEPAGE="http://www.gnu.org/software/libidn/"
SRC_URI="ftp://alpha.gnu.org/pub/gnu/libidn/${P}.tar.gz"

LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="java doc emacs mono nls"

COMMON_DEPEND="emacs? ( virtual/emacs )
	mono? ( >=dev-lang/mono-0.95 )"
DEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jdk-1.4 dev-java/gjdoc )"
RDEPEND="${COMMON_DEPEND}
	java? ( >=virtual/jre-1.4 )"

src_unpack() {
	unpack ${A}
	# bundled, with wrong bytecode
	rm "${S}/java/${P}.jar" || die
}

src_compile() {
	econf \
		$(use_enable nls) \
		$(use_enable java) \
		$(use_enable mono csharp mono) \
		--with-lispdir="${ESITELISP}/${PN}" \
		|| die

	emake || die

	if use emacs; then
		elisp-compile src/*.el || die
	fi
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog FAQ NEWS README THANKS TODO || die

	if use emacs; then
		# *.el are installed by the build system
		elisp-install ${PN} src/*.elc || die
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" || die
	else
		rm -rf "${ED}/usr/share/emacs"
	fi

	#use xemacs || rm -rf "${ED}/usr/lib/xemacs"

	if use doc ; then
		dohtml -r doc/reference/html/* || die
	fi

	if use java ; then
		java-pkg_newjar "${ED}"/usr/share/java/${P}.jar || die
		rm -rf "${ED}"/usr/share/java || die

		if use doc ; then
			java-pkg_dojavadoc doc/java
		fi
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
