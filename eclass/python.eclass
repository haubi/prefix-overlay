# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python.eclass,v 1.34 2008/03/28 07:11:57 hawking Exp $

# @ECLASS: python.eclass
# @MAINTAINER:
# python@gentoo.org
#
# original author: Alastair Tse <liquidx@gentoo.org>
# @BLURB: A Utility Eclass that should be inherited by anything that deals with Python or Python modules.
# @DESCRIPTION:
# Some useful functions for dealing with python.
inherit alternatives multilib


if [[ -n "${NEED_PYTHON}" ]] ; then
	DEPEND=">=dev-lang/python-${NEED_PYTHON}"
	RDEPEND="${DEPEND}"
fi

__python_eclass_test() {
	__python_version_extract 2.3
	echo -n "2.3 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.3.4
	echo -n "2.3.4 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.3.5
	echo -n "2.3.5 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.4
	echo -n "2.4 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.5b3
	echo -n "2.5b3 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
}

# @FUNCTION: python_disable_pyc
# @DESCRIPTION:
# Tells python not to automatically recompile modules to .pyc/.pyo
# even if the timestamps/version stamps don't match. This is done
# to protect sandbox.
#
# note:   supported by >=dev-lang/python-2.2.3-r3 only.
#
python_disable_pyc() {
	export PYTHON_DONTCOMPILE=1
}

# @FUNCTION: python_enable_pyc
# @DESCRIPTION:
# Tells python to automatically recompile modules to .pyc/.pyo if the
# timestamps/version stamps change
python_enable_pyc() {
	unset PYTHON_DONTCOMPILE
}

python_disable_pyc

# @FUNCTION: python_version
# @DESCRIPTION:
# Run without arguments and it will export the version of python
# currently in use as $PYVER; sets PYVER/PYVER_MAJOR/PYVER_MINOR
__python_version_extract() {
	verstr=$1
	export PYVER_MAJOR=${verstr:0:1}
	export PYVER_MINOR=${verstr:2:1}
	if [ "${verstr:3}x" = ".x" ]; then
		export PYVER_MICRO=${verstr:4}
	fi
	export PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"
}

python_version() {
	local tmpstr
	python=${python:-${EPREFIX}/usr/bin/python}
	tmpstr="$(${python} -V 2>&1 )"
	export PYVER_ALL="${tmpstr#Python }"
	__python_version_extract $PYVER_ALL
}

# @FUNCTION: python_makesym
# @DESCRIPTION:
# Run without arguments, it will create the /usr/bin/python symlinks
# to the latest installed version
python_makesym() {
	alternatives_auto_makesym "/usr/bin/python" "python[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python2" "python2.[0-9]"
}

# @FUNCTION: python_tkinter_exists
# @DESCRIPTION:
# Run without arguments, checks if python was compiled with Tkinter
# support.  If not, prints an error message and dies.
python_tkinter_exists() {
	if ! python -c "import Tkinter" >/dev/null 2>&1; then
		eerror "You need to recompile python with Tkinter support."
		eerror "Try adding: 'dev-lang/python tk'"
		eerror "in to ${EPREFIX}/etc/portage/package.use"
		echo
		die "missing tkinter support with installed python"
	fi
}

# @FUNCTION: python_mod_exists
# @USAGE: < module >
# @DESCRIPTION:
# Run with the module name as an argument. it will check if a
# python module is installed and loadable. it will return
# TRUE(0) if the module exists, and FALSE(1) if the module does
# not exist.
#
# Example:
#         if python_mod_exists gtk; then
#             echo "gtk support enabled"
#         fi
python_mod_exists() {
	[ -z "$1" ] && die "${FUNCTION} requires an argument!"
	if ! python -c "import $1" >/dev/null 2>&1; then
		return 1
	fi
	return 0
}

# @FUNCTION: python_mod_compile
# @USAGE: < file >
# @DESCRIPTION:
# Given a filename, it will pre-compile the module's .pyc and .pyo.
# should only be run in pkg_postinst()
#
# Example:
#         python_mod_compile ${EROOT}usr/lib/python2.3/site-packages/pygoogle.py
#
python_mod_compile() {
	# allow compiling for older python versions
	if [ -n "${PYTHON_OVERRIDE_PYVER}" ]; then
		PYVER=${PYTHON_OVERRIDE_PYVER}
	else
		python_version
	fi

	if [ -f "$1" ]; then
		python${PYVER} -c "import py_compile; py_compile.compile('${1}')" || \
			ewarn "Failed to compile ${1}"
		python${PYVER} -O -c "import py_compile; py_compile.compile('${1}')" || \
			ewarn "Failed to compile ${1}"
	else
		ewarn "Unable to find ${1}"
	fi
}

# @FUNCTION: python_mod_optimize
# @USAGE: [ path ]
# @DESCRIPTION:
# If no arguments supplied, it will recompile all modules under
# sys.path (eg. /usr/lib/python2.3, /usr/lib/python2.3/site-packages/ ..)
# no recursively
#
# If supplied with arguments, it will recompile all modules recursively
# in the supplied directory
#
# Example:
#         python_mod_optimize ${EROOT}usr/share/codegen
python_mod_optimize() {
	local myroot
	# strip trailing slash
	myroot="${EROOT%/}"

	# allow compiling for older python versions
	if [ -n "${PYTHON_OVERRIDE_PYVER}" ]; then
		PYVER=${PYTHON_OVERRIDE_PYVER}
	else
		python_version
	fi

	# set opts
	if [ "${PYVER}" = "2.2" ]; then
		compileopts=""
	else
		compileopts="-q"
	fi

	ebegin "Byte compiling python modules for python-${PYVER} .."
	python${PYVER} ${myroot}/usr/$(get_libdir)/python${PYVER}/compileall.py ${compileopts} $@
	python${PYVER} -O ${myroot}/usr/$(get_libdir)/python${PYVER}/compileall.py ${compileopts} $@
	eend $?
}

# @FUNCTION: python_mod_cleanup
# @USAGE: [ dir ]
# @DESCRIPTION:
# Run with optional arguments, where arguments are directories of
# python modules. if none given, it will look in /usr/lib/python[0-9].[0-9]
#
# It will recursively scan all compiled python modules in the directories
# and determine if they are orphaned (eg. their corresponding .py is missing.)
# if they are, then it will remove their corresponding .pyc and .pyo
python_mod_cleanup() {
	local SEARCH_PATH myroot

	# strip trailing slash
	myroot="${ROOT%/}"

	if [ $# -gt 0 ]; then
		for path in $@; do
			path=${path#${EPREFIX}}
			SEARCH_PATH="${SEARCH_PATH} ${myroot}${EPREFIX}/${path#/}"
		done
	else
		for path in ${myroot}${EPREFIX}/usr/lib*/python*/site-packages; do
			SEARCH_PATH="${SEARCH_PATH} ${path}"
		done
	fi

	for path in ${SEARCH_PATH}; do
		einfo "Cleaning orphaned Python bytecode from ${path} .."
		for obj in $(find ${path} -name '*.py[co]'); do
			src_py="${obj%[co]}"
			if [ ! -f "${src_py}" ]; then
				einfo "Purging ${src_py}[co]"
				rm -f ${src_py}[co]
			fi
		done
		# attempt to remove directories that maybe empty
		for dir in $(find ${path} -type d | sort -r); do
			rmdir ${dir} 2>/dev/null
		done
	done
}
