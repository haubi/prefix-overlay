# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/skk-jisyo/skk-jisyo-200707.ebuild,v 1.3 2007/08/11 17:55:00 matsuu Exp $

EAPI="prefix"

DESCRIPTION="Jisyo (dictionary) files for the SKK Japanese-input software"
HOMEPAGE="http://openlab.ring.gr.jp/skk/dic.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2 public-domain freedist"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86"
IUSE="cdb"

DEPEND="sys-apps/gawk
	cdb? ( || (
		dev-db/cdb
		dev-db/tinycdb
		dev-db/freecdb
	) )
	!app-i18n/skk-jisyo-extra
	!app-i18n/skk-jisyo-cdb"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm SKK-JISYO.wrong.annotated SKK-JISYO.china_taiwan.header
	rm SKK-JISYO.noregist SKK-JISYO.not_wrong SKK-JISYO.hukugougo
	rm SKK-JISYO.notes SKK-JISYO.requested SKK-JISYO.pubdic+
}

src_compile() {
	# bug 184457
	unset LANG LC_ALL LC_CTYPE

	for f in SKK-JISYO.* zipcode/SKK-JISYO.* ; do
		mv ${f} ${f}.annotated
		awk -f "${FILESDIR}"/unannotation.awk ${f}.annotated > $(basename ${f}) || die
		if use cdb ; then
			awk '
				/^[^;]/ {
					s = substr($0, index($0, " ") + 1)
					print "+" length($1) "," length(s) ":" $1 "->" s
				}
				END {
					print ""
				}
			' $(basename ${f}) | cdbmake $(basename ${f}).cdb "${T}"/$(basename ${f}) || die
		fi
		rm ${f}.annotated
	done
}

src_install() {
	# install dictionaries
	insinto /usr/share/skk
	doins SKK-JISYO.* || die

	dodoc ChangeLog* READMEs/committers.txt edict_doc.txt
}
