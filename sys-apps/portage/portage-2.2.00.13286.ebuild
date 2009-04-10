# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="prefix"

RESTRICT="test"

inherit eutils multilib python

DESCRIPTION="Prefix branch of the Portage Package Manager, used in Gentoo Prefix"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
PROVIDE="virtual/portage"
SLOT="0"
IUSE="build doc epydoc selinux linguas_pl prefix-chaining"

python_dep=">=dev-lang/python-2.4"

DEPEND="${python_dep}
	!build? ( >=sys-apps/sed-4.0.5 )
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
RDEPEND="${python_dep}
	!build? ( >=sys-apps/sed-4.0.5
		>=app-shells/bash-3.2_p17
		>=app-admin/eselect-news-20071201 )
	!prefix? ( elibc_FreeBSD? ( sys-freebsd/freebsd-bin ) )
	elibc_glibc? ( >=sys-apps/sandbox-1.2.17 !mips? ( >=sys-apps/sandbox-1.2.18.1-r2 ) )
	elibc_uclibc? ( >=sys-apps/sandbox-1.2.17 !mips? ( >=sys-apps/sandbox-1.2.18.1-r2 ) )
	kernel_linux? ( >=app-misc/pax-utils-0.1.17 )
	kernel_SunOS? ( >=app-misc/pax-utils-0.1.17 )
	kernel_FreeBSD? ( >=app-misc/pax-utils-0.1.17 )
	kernel_Darwin? ( >=app-misc/pax-utils-0.1.18 )
	selinux? ( >=dev-python/python-selinux-2.16 )"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
		|| ( >=dev-lang/python-2.5 >=dev-python/pycrypto-2.0.1-r6 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# rsync-2.6.4 rdep is for the --filter option #167668

SRC_ARCHIVES="http://dev.gentoo.org/~grobian/distfiles http://dev.gentoo.org/~zmedico/portage/archives"

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

PV_PL="2.1.2"
PATCHVER_PL=""
TARBALL_PV="${PV}"
SRC_URI="$(prefix_src_archives prefix-${PN}-${TARBALL_PV}.tar.bz2)
	linguas_pl? ( $(prefix_src_archives ${PN}-man-pl-${PV_PL}.tar.bz2) )"

#PATCHVER=$PV  # in prefix we don't do this
if [ -n "${PATCHVER}" ]; then
	SRC_URI="${SRC_URI} mirror://gentoo/${PN}-${PATCHVER}.patch.bz2
	$(prefix_src_archives ${PN}-${PATCHVER}.patch.bz2)"
fi

S="${WORKDIR}"/prefix-${PN}-${TARBALL_PV}
S_PL="${WORKDIR}"/${PN}-${PV_PL}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [ -n "${PATCHVER}" ]; then
		cd "${S}"
		epatch "${WORKDIR}/${PN}-${PATCHVER}.patch"
	fi

	use prefix-chaining && epatch "${FILESDIR}"/${PN}-2.2.00.13133-prefix-chaining.patch
}

src_compile() {
	econf \
		--with-portage-user="${PORTAGE_USER:-portage}" \
		--with-portage-group="${PORTAGE_GROUP:-portage}" \
		--with-root-user="$(python -c 'from portage.const import rootuser; print rootuser')" \
		--with-offset-prefix="${EPREFIX}" \
		--with-default-path="/usr/bin:/bin" \
		|| die "econf failed"
	emake || die "emake failed"

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	if use doc; then
		cd "${S}"/doc
		touch fragment/date
		emake xhtml xhtml-nochunks || die "failed to make docs"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules epydoc_opts=""
		# A name collision between the portage.dbapi class and the
		# module with the same name triggers an epydoc crash unless
		# portage.dbapi is excluded from introspection.
		ROOT=/ has_version '>=dev-python/epydoc-3_pre0' && \
			epydoc_opts='--exclude-introspect portage\.dbapi'
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:/__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g' | sort)" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --no-frames --show-imports $epydoc_opts \
			--name "${PN}" --url "${HOMEPAGE}" \
			${my_modules} || die "epydoc failed"
	fi
}

src_test() {
	./pym/portage/tests/runTests || \
		die "test(s) failed"
}

src_install() {
	local libdir=$(get_libdir)
	local portage_base="/usr/${libdir}/portage"

	emake DESTDIR="${D}" install || die "make install failed."
	dodir /usr/lib/portage/bin

	# die, stupid wrapper, die!
	use prefix && rm -Rf "${ED}"${portage_base}/bin/ebuild-helpers/sed

	# Symlinks to directories cause up/downgrade issues and the use of these
	# modules outside of portage is probably negligible.
	for x in "${ED}${portage_base}/pym/"{cache,elog_modules} ; do
		[ ! -L "${x}" ] && continue
		die "symlink to directory will cause upgrade/downgrade issues: '${x}'"
	done

	exeinto ${portage_base}/pym/portage/tests
	doexe  "${S}"/pym/portage/tests/runTests


	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9]
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9]
	fi

	dodoc "${S}"/{ChangeLog,NEWS,RELEASE-NOTES}
	use doc && dohtml -r "${S}"/doc/*
	use epydoc && dohtml -r "${WORKDIR}"/api
	dodir /etc/portage
	keepdir /etc/portage
}

pkg_preinst() {
	if ! use build && ! has_version dev-python/pycrypto && \
		has_version '>=dev-lang/python-2.5' ; then
		if ! built_with_use '>=dev-lang/python-2.5' ssl ; then
			ewarn "If you are an ebuild developer and you plan to commit ebuilds"
			ewarn "with this system then please install dev-python/pycrypto or"
			ewarn "enable the ssl USE flag for >=dev-lang/python-2.5 in order"
			ewarn "to enable RMD160 hash support."
			ewarn "See bug #198398 for more information."
		fi
	fi
	if [ -f "${EROOT}/etc/make.globals" ]; then
		rm "${EROOT}/etc/make.globals"
	fi

}

pkg_postinst() {
	# Compile all source files recursively. Any orphans
	# will be identified and removed in postrm.
	python_mod_optimize /usr/$(get_libdir)/portage/pym

	pushd "${EROOT}var/db/pkg" > /dev/null
	local didwork=
	[[ ! -e "${EROOT}"var/lib/portage/preserved_libs_registry ]] && for cpv in */*/NEEDED ; do
		if [[ ${CHOST} == *-darwin* && ! -f ${cpv}.MACHO.3 ]] ; then
			while read line; do
				scanmacho -BF "%a;%F;%S;%n" ${line% *} >> "${cpv}".MACHO.3
			done < "${cpv}"
			[[ -z ${didwork} ]] \
				&& didwork=yes \
				|| didwork=already
		elif [[ ${CHOST} != *-darwin* && ! -f ${cpv}.ELF.2 ]] ; then
			while read line; do
				filename=${line% *}
				needed=${line#* }
				newline=$(scanelf -BF "%a;%F;%S;$needed;%r" $filename)
				echo "${newline:3}" >> "${cpv}".ELF.2
			done < "${cpv}"
			[[ -z ${didwork} ]] \
				&& didwork=yes \
				|| didwork=already
		fi
		[[ ${didwork} == yes ]] && \
			einfo "converting NEEDED files to new syntax, please wait"
	done
	popd > /dev/null
	elog
	elog "For help with using portage please consult the Gentoo Handbook"
	elog "at http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3"
	elog

	if [ x$MINOR_UPGRADE = x0 ] ; then
		elog "If you're upgrading from a pre-2.2 version of portage you might"
		elog "want to remerge world (emerge -e world) to take full advantage"
		elog "of some of the new features in 2.2."
		elog "This is not required however for portage to function properly."
		elog
	fi

	if [ -z "${PV/*_pre*}" ]; then
		elog "If you always want to use the latest development version of portage"
		elog "please read http://www.gentoo.org/proj/en/portage/doc/testing.xml"
		elog
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/portage/pym
}
