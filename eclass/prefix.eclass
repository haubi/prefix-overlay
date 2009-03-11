# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

#
# @ECLASS: prefix.eclass
# @MAINTAINER:
# Feel free to contact the Prefix team through <prefix@gentoo.org> if
# you have problems, suggestions or questions.
# @BLURB: Eclass to provide Prefix functionality
# @DESCRIPTION:
# Gentoo Prefix allows users to install into a self defined offset
# located somewhere in the filesystem.  Prefix ebuilds require
# additional functions and variables which are defined by this eclass.

# @ECLASS-VARIABLE: EPREFIX
# @DESCRIPTION:
# The offset prefix of a Gentoo Prefix installation.  When Gentoo Prefix
# is not used, ${EPREFIX} should be "".  Prefix Portage sets EPREFIX,
# hence this eclass has nothing to do here in that case.
# Note that setting EPREFIX in the environment with Prefix Portage sets
# Portage into cross-prefix mode.

# @ECLASS-VARIABLE: EROOT
# @DESCRIPTION:
# The offset prefix appended to ${ROOT}.  Prefix Portage sets this
# variable automatically.

# @ECLASS-VARIABLE: ED
# @DESCRIPTION:
# The offset prefix appended to ${D}.  Prefix Portage sets this variable
# automatically.  It is questionable if ${D} is (supposed to be) set
# when this eclass is sourced, so this might not work out in non-Prefix.

if [[ ${EPREFIX+yes}${EROOT+we}${ED+can} != "yeswecan" ]]; then
	export EPREFIX=''
	export EROOT=${ROOT}
	export ED=${D}
fi

# @FUNCTION: eprefixify
# @USAGE: <list of to be eprefixified files>
# @DESCRIPTION:
# replaces @GENTOO_PORTAGE_EPREFIX@ with ${EPREFIX} for the given files,
# dies if no arguments are given, a file does not exist, or changing a
# file failed.
eprefixify() {
	[[ $# -lt 1 ]] && die "at least one argument needed"

	einfo "Adjusting to prefix"
	for x in "$@" ; do
		if [[ -e ${x} ]] ; then
			ebegin "  ${x##*/}"
			sed -i -e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" "${x}"
			r=$?
			eend ${r}
			[[ ${r} != 0 ]] && die "failed to eprefixify ${x}"
		else
			die "${x} does not exist"
		fi
	done
}


# vim: tw=72:
