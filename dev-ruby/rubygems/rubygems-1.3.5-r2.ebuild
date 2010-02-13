# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/rubygems/rubygems-1.3.5-r2.ebuild,v 1.2 2010/01/31 23:11:51 flameeyes Exp $

EAPI="2"

USE_RUBY="ruby18 jruby"

inherit ruby-ng prefix

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="http://rubyforge.org/projects/rubygems/"
LICENSE="|| ( Ruby GPL-2 )"

# Needs to be installed first
RESTRICT="test"

SRC_URI="mirror://rubyforge/${PN}/${P}.tgz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="doc server"

# previous versions had rubygems bundled, so it would collide badly
RDEPEND="ruby_targets_jruby? ( >=dev-java/jruby-1.4.0-r5 )"

# index_gem_repository.rb
PDEPEND="server? ( dev-ruby/builder[ruby_targets_ruby18] )"

USE_RUBY="ruby18"

all_ruby_prepare() {
	epatch "${FILESDIR}/${PN}-1.3.5-setup.patch"
	# Fixes a new "feature" that would prevent us from recognizing installed
	# gems inside the sandbox
	epatch "${FILESDIR}/${PN}-1.3.3-gentoo.patch"

	epatch "${FILESDIR}"/${PN}-1.3.3-prefix.patch
	eprefixify lib/rubygems/config_file.rb
}

each_ruby_install() {
	# RUBYOPT=-rauto_gem without rubygems installed will cause ruby to fail, bug #158455
	export RUBYOPT="${GENTOO_RUBYOPT}"
	ewarn "RUBYOPT=${RUBYOPT}"

	local gemsitedir=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitelibdir"]' | sed -e 's:site_ruby:gems:')

	# rubygems tries to create GEM_HOME if it doesn't exist, upsetting sandbox,
	# bug #202109. Since 1.2.0 we also need to set GEM_PATH
	# for this reason, bug #230163.
	export GEM_HOME="${D}${gemsitedir}"
	export GEM_PATH="${GEM_HOME}/"
	keepdir ${gemsitedir#${EPREFIX}}/{doc,gems,cache,specifications}

	myconf=""
	if ! use doc; then
		myconf="${myconf} --no-ri"
		myconf="${myconf} --no-rdoc"
	fi

	${RUBY} setup.rb $myconf --destdir="${D}" || die "setup.rb install failed"

	doruby "${FILESDIR}/auto_gem.rb"
}

all_ruby_install() {
	dodoc README || die "dodoc README failed"

	doenvd "${FILESDIR}/10rubygems" || die "doenvd 10rubygems failed"

	if use server; then
		newinitd "${FILESDIR}/init.d-gem_server2" gem_server || die "newinitd failed"
		newconfd "${FILESDIR}/conf.d-gem_server" gem_server || die "newconfd failed"
	fi
}

pkg_postinst() {
	local gemsitedir=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitelibdir"]' | sed -e 's:site_ruby:gems:')
	SOURCE_CACHE="${gemsitedir}/source_cache"
	if [[ -e "${SOURCE_CACHE}" ]]; then
		rm "${SOURCE_CACHE}"
	fi

	if [[ ! -n $(readlink "${EROOT}"usr/bin/gem) ]] ; then
		eselect ruby set ruby18
	fi

	ewarn
	ewarn "This ebuild is compatible to eselect-ruby"
	ewarn "To switch between available Ruby profiles, execute as root:"
	ewarn "\teselect ruby set ruby(18|19|...)"
	ewarn
}

pkg_postrm() {
	ewarn "If you have uninstalled dev-ruby/rubygems, Ruby applications are unlikely"
	ewarn "to run in current shells because of missing auto_gem."
	ewarn "Please run \"unset RUBYOPT\" in your shells before using ruby"
	ewarn "or start new shells"
	ewarn
	ewarn "If you have not uninstalled dev-ruby/rubygems, please do not unset "
	ewarn "RUBYOPT"
}
