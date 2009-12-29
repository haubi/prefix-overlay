# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/ruby-fakegem.eclass,v 1.8 2009/12/26 17:06:02 flameeyes Exp $
#
# @ECLASS: ruby-fakegem.eclass
# @MAINTAINER:
# Ruby herd <ruby@gentoo.org>
#
# Author: Diego E. Pettenò <flameeyes@gentoo.org>
#
# Author: Alex Legler <a3li@gentoo.org>
#
# @BLURB: An eclass for installing Ruby packages to behave like RubyGems.
# @DESCRIPTION:
# This eclass allows to install arbitrary Ruby libraries (including Gems),
# providing integration into the RubyGems system even for "regular" packages.
#

inherit ruby-ng

# @ECLASS-VARIABLE: RUBY_FAKEGEM_NAME
# @DESCRIPTION:
# Sets the Gem name for the generated fake gemspec.
# RUBY_FAKEGEM_NAME="${PN}"

# @ECLASS-VARIABLE: RUBY_FAKEGEM_VERSION
# @DESCRIPTION:
# Sets the Gem version for the generated fake gemspec.
# RUBY_FAKEGEM_VERSION="${PV}"

# @ECLASS-VARIABLE: RUBY_FAKEGEM_TASK_DOC
# @DESCRIPTION:
# Specify the rake(1) task to run to generate documentation.
# RUBY_FAKEGEM_TASK_DOC="rdoc"

# @ECLASS-VARIABLE: RUBY_FAKEGEM_TASK_TEST
# @DESCRIPTION:
# Specify the rake(1) task used for executing tests.
# RUBY_FAKEGEM_TASK_TEST="test"

# @ECLASS-VARIABLE: RUBY_FAKEGEM_DOCDIR
# @DESCRIPTION:
# Specify the directory under which the documentation is built;
# if empty no documentation will be installed automatically.
# RUBY_FAKEGEM_DOCDIR=""

# @ECLASS-VARIABLE: RUBY_FAKEGEM_EXTRADOC
# @DESCRIPTION:
# Extra documentation to install (readme, changelogs, …).
# RUBY_FAKEGEM_EXTRADOC=""

# @ECLASS-VARIABLE: RUBY_FAKEGEM_BINWRAP
# @DESCRIPTION:
# Binaries to wrap around (relative to the bin/ directory)
# RUBY_FAKEGEM_BINWRAP="*"

# @ECLASS-VARIABLE: RUBY_FAKEGEM_REQUIRE_PATHS
# @DESCRIPTION:
# Extra require paths (beside lib) to add to the specification
# RUBY_FAKEGEM_BINWRAP=""

RUBY_FAKEGEM_NAME="${RUBY_FAKEGEM_NAME:-${PN}}"
RUBY_FAKEGEM_VERSION="${RUBY_FAKEGEM_VERSION:-${PV}}"

RUBY_FAKEGEM_TASK_DOC="${RUBY_FAKEGEM_TASK_DOC-rdoc}"
RUBY_FAKEGEM_TASK_TEST="${RUBY_FAKEGEM_TASK_TEST-test}"

RUBY_FAKEGEM_BINWRAP="${RUBY_FAKEGEM_BINWRAP-*}"

if [[ ${RUBY_FAKEGEM_TASK_DOC} != "" ]]; then
	IUSE="$IUSE doc"
	ruby_add_bdepend doc "dev-ruby/rake"
fi

if [[ ${RUBY_FAKEGEM_TASK_TEST} != "" ]]; then
	IUSE="$IUSE test"
	ruby_add_bdepend test "dev-ruby/rake"
fi

SRC_URI="mirror://rubygems/${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}.gem"

ruby_add_rdepend virtual/rubygems

# @FUNCTION: ruby_fakegem_gemsdir
# @RETURN: Returns the gem data directory
# @DESCRIPTION:
# This function returns the gems data directory for the ruby
# implementation in question.
ruby_fakegem_gemsdir() {
	local _gemsitedir=$(${RUBY} -r rbconfig -e 'print Config::CONFIG["sitelibdir"]' | sed -e 's:site_ruby:gems:' -e "s:^${EPREFIX}::")

	[[ -z ${_gemsitedir} ]] && {
		eerror "Unable to find the gems dir"
		die "Unable to find the gems dir"
	}

	echo "${_gemsitedir}"
}

# @FUNCTION: ruby_fakegem_doins
# @USAGE: file [file...]
# @DESCRIPTION:
# Installs the specified file(s) into the gems directory.
ruby_fakegem_doins() {
	(
		insinto $(ruby_fakegem_gemsdir)/gems/${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}
		doins "$@"
	) || die "failed $0 $@"
}

# @FUNCTION: ruby_fakegem_newsins()
# @USAGE: file filename
# @DESCRIPTION:
# Installs the specified file into the gems directory using the provided filename.
ruby_fakegem_newins() {
	(
		# Since newins does not accept full paths but just basenames
		# for the target file, we want to extend it here.
		local newdirname=/$(dirname "$2")
		[[ ${newdirname} == "/." ]] && newdirname=

		local newbasename=$(basename "$2")

		insinto $(ruby_fakegem_gemsdir)/gems/${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}${newdirname}
		newins "$1" ${newbasename}
	) || die "failed $0 $@"
}

# @FUNCTION: ruby_fakegem_genspec
# @DESCRIPTION:
# Generates a gemspec for the package and places it into the "specifications"
# directory of RubyGems.
# In the gemspec, the following values are set: name, version, summary,
# homepage, and require_paths=["lib"].
# See RUBY_FAKEGEM_NAME and RUBY_FAKEGEM_VERSION for setting name and version.
# See RUBY_FAKEGEM_REQUIRE_PATHS for setting extra require paths.
ruby_fakegem_genspec() {
	(
		local required_paths="'lib'"
		for path in ${RUBY_FAKEGEM_REQUIRE_PATHS}; do
			required_paths="${required_paths}, '${path}'"
		done

		# We use the _ruby_implementation variable to avoid having stray
		# copies with different implementations; while for now we're using
		# the same exact content, we might have differences in the future,
		# so better taking this into consideration.
		cat - > "${T}"/${RUBY_FAKEGEM_NAME}-${_ruby_implementation} <<EOF
Gem::Specification.new do |s|
  s.name = "${RUBY_FAKEGEM_NAME}"
  s.version = "${RUBY_FAKEGEM_VERSION}"
  s.summary = "${DESCRIPTION}"
  s.homepage = "${HOMEPAGE}"
  s.require_paths = [${required_paths}]
end
EOF

		insinto $(ruby_fakegem_gemsdir)/specifications
		newins "${T}"/${RUBY_FAKEGEM_NAME}-${_ruby_implementation} ${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}.gemspec
	) || die "Unable to install fake gemspec"
}

# @FUNCTION: ruby_fakegem_binwrapper
# @USAGE: command [path]
# @DESCRIPTION:
# Creates a new binary wrapper for a command installed by the RubyGem.
# path defaults to /usr/bin/$command
ruby_fakegem_binwrapper() {
	(
		local gembinary=$1
		local newbinary=${2:-/usr/bin/$gembinary}
		local relativegembinary=${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}/bin/${gembinary}

		cat - > "${T}"/gembin-wrapper-${gembinary} <<EOF
#!/usr/bin/env ruby
# This is a simplified version of the RubyGems wrapper
#
# Generated by ruby-fakegem.eclass

require 'rubygems'

load Gem::default_path[-1] + "/gems/${relativegembinary}"

EOF

		exeinto $(dirname $newbinary)
		newexe "${T}"/gembin-wrapper-${gembinary} $(basename $newbinary)
	) || die "Unable to create fakegem wrapper"
}

# @FUNCTION: all_fakegem_compile
# @DESCRIPTION:
# Build documentation for the package if indicated by the doc USE flag
# and if there is a documetation task defined.
all_fakegem_compile() {
	if [[ ${RUBY_FAKEGEM_TASK_DOC} != "" ]] && use doc; then
		rake ${RUBY_FAKEGEM_TASK_DOC} || die "failed to (re)build documentation"
	fi
}

# @FUNCTION: all_ruby_unpack
# @DESCRIPTION:
# Unpack the source archive, including support for unpacking gems.
all_ruby_unpack() {
	# Special support for extracting .gem files; the file need to be
	# extracted twice and the mtime from the archive _has_ to be
	# ignored (it's always set to epoch 0).
	#
	# This only works if there is exactly one archive and that archive
	# is a .gem file!
	if [[ $(wc -w <<< ${A}) == 1 ]] &&
		[[ ${A} == *.gem ]]; then
		ebegin "Unpacking .gem file..."
		tar -mxf ${DISTDIR}/${A} || die
		eend $?

		mkdir "${S}"
		pushd "${S}"

		ebegin "Unpacking data.tar.gz"
		tar -mxf "${my_WORKDIR}"/data.tar.gz || die
		eend $?
	else
		[[ -n ${A} ]] && unpack ${A}
	fi
}

# @FUNCTION: all_ruby_compile
# @DESCRIPTION:
# Compile the package.
all_ruby_compile() {
	all_fakegem_compile
}

# @FUNCTION: each_fakegem_test
# @DESCRIPTION:
# Run tests for the package for each ruby target if the test task is defined.
each_fakegem_test() {
	local rubyflags=

	if [[ ${RUBY_FAKEGEM_TASK_TEST} != "" ]]; then
		${RUBY} ${rubyflags} -S rake ${RUBY_FAKEGEM_TASK_TEST} || die "tests failed"
	else
		echo "No test task defined, skipping tests."
	fi
}

# @FUNCTION: each_ruby_test
# @DESCRIPTION:
# Run the tests for this package.
each_ruby_test() {
	each_fakegem_test
}

# @FUNCTION: each_fakegem_install
# @DESCRIPTION:
# Install the package for each ruby target.
each_fakegem_install() {
	ruby_fakegem_genspec

	local _gemlibdirs=
	for directory in bin lib ${RUBY_FAKEGEM_EXTRAINSTALL}; do
		[[ -d ${directory} ]] && _gemlibdirs="${_gemlibdirs} ${directory}"
	done

	ruby_fakegem_doins -r ${_gemlibdirs}
}

# @FUNCTION: each_ruby_install
# @DESCRIPTION:
# Install the package for each target.
each_ruby_install() {
	each_fakegem_install
}

# @FUNCTION: all_fakegem_install
# @DESCRIPTION:
# Install files common to all ruby targets.
all_fakegem_install() {
	if [[ -n ${RUBY_FAKEGEM_DOCDIR} ]] && use doc; then
		for dir in ${RUBY_FAKEGEM_DOCDIR}; do
			pushd ${dir}
			dohtml -r * || die "failed to install documentation"
			popd
		done
	fi

	if [[ -n ${RUBY_FAKEGEM_EXTRADOC} ]]; then
		dodoc ${RUBY_FAKEGEM_EXTRADOC} || die "failed to install further documentation"
	fi

	# binary wrappers; we assume that all the implementations get the
	# same binaries, or something is wrong anyway, so...
	if [[ -n ${RUBY_FAKEGEM_BINWRAP} ]]; then
		local bindir=$(find "${ED}" -type d -path "*/gems/${RUBY_FAKEGEM_NAME}-${RUBY_FAKEGEM_VERSION}/bin" -print -quit)

		if [[ -d "${bindir}" ]]; then
			pushd "${bindir}"
			local binaries=$(eval ls ${RUBY_FAKEGEM_BINWRAP})
			for binary in $binaries; do
				ruby_fakegem_binwrapper $binary
			done
			popd
		fi
	fi
}

# @FUNCTION: all_ruby_install
# @DESCRIPTION:
# Install files common to all ruby targets.
all_ruby_install() {
	all_fakegem_install
}
