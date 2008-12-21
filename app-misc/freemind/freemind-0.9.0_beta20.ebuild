# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/freemind/freemind-0.9.0_beta20.ebuild,v 1.1 2008/12/20 22:40:05 caster Exp $

EAPI="prefix 1"

# will handle rewriting myself
JAVA_PKG_BSFIX="off"
WANT_ANT_TASKS="ant-nodeps ant-trax"
inherit java-pkg-2 java-ant-2 eutils

MY_PV=${PV//beta/Beta_}

DESCRIPTION="Mind-mapping software written in Java"
HOMEPAGE="http://freemind.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${MY_PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc groovy latex pdf svg"
COMMON_DEP="dev-java/jgoodies-forms:0
	dev-java/jibx:0
	>=dev-java/simplyhtml-0.12.3:0
	dev-java/commons-lang:2.1
	dev-java/javahelp:0
	groovy? ( dev-java/groovy:1 )
	latex? ( dev-java/hoteqn:0 )
	pdf? ( dev-java/batik:1.6
		>=dev-java/fop-0.93:0 )
	svg? ( dev-java/batik:1.6
		>=dev-java/fop-0.93:0 )"
DEPEND=">=virtual/jdk-1.4
	dev-java/xsd2jibx:0
	app-arch/unzip
	kernel_Darwin? ( dev-java/jarbundler )
	${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# kill the jarbundler taskdef
	[[ ${CHOST} == *-darwin* ]] && \
	sed -i -e 's:"${src}/lib/${jarbundler.jar}":"${jarblibs}":' build.xml || \
	epatch "${FILESDIR}/${PN}-0.9.0_beta15-build.xml.patch"

	local xml
	for xml in $(find . -name 'build*.xml'); do
		java-ant_rewrite-classpath ${xml}
		java-ant_bsfix_one ${xml}
	done
	rm -v lib/*.jar lib/*.zip lib/*/*.jar \
		plugins/*/*.jar plugins/*/*/*.jar || die

	use groovy || rm plugins/build_scripting.xml || die
	use latex || rm plugins/build_latex.xml || die
	if ! use pdf && ! use svg ; then
		rm plugins/build_svg.xml || die
	fi
}

src_compile() {
	local jibxlibs="$(java-pkg_getjars --build-only --with-dependencies xsd2jibx)"
	local gcp="jgoodies-forms,jibx,commons-lang-2.1,javahelp,simplyhtml"
	use groovy && gcp="${gcp},groovy-1"
	use latex && gcp="${gcp},hoteqn"
	if use pdf || use svg ; then
		gcp="${gcp},batik-1.6,fop"
	fi
	local gcp="$(java-pkg_getjars --with-dependencies ${gcp}):lib/bindings.jar"
	local jarblibs=""
	[[ ${CHOST} == *-darwin* ]] && \
		jarblibs="$(java-pkg_getjars --build-only --with-dependencies jarbundler)"
	ANT_TASKS="${WANT_ANT_TASKS} jibx xsd2jibx" eant -Djibxlibs="${jibxlibs}" \
		-Djarblibs="${jarblibs}" \
		-Dgentoo.classpath="${gcp}" dist browser $(use_doc doc)
}

src_install() {
	cd "${WORKDIR}/bin/dist"
	local dest="/usr/share/${PN}/"

	java-pkg_dojar lib/*.jar

	insinto "${dest}"
	doins -r accessories browser/ doc/ plugins/ patterns.xml || die

	use doc && java-pkg_dojavadoc doc/javadoc

	java-pkg_dolauncher ${PN} --java_args "-Dfreemind.base.dir=${EPREFIX}${dest}" \
		--pwd "${EPREFIX}${dest}" --main freemind.main.FreeMindStarter

	newicon "${S}/images/FreeMindWindowIcon.png" freemind.png

	make_desktop_entry freemind Freemind freemind Utility
}
