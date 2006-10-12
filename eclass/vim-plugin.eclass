# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/vim-plugin.eclass,v 1.18 2006/10/10 15:47:34 pioto Exp $
#
# This eclass simplifies installation of app-vim plugins into
# /usr/share/vim/vimfiles.  This is a version-independent directory
# which is read automatically by vim.  The only exception is
# documentation, for which we make a special case via vim-doc.eclass

inherit vim-doc
EXPORT_FUNCTIONS src_install pkg_postinst pkg_postrm

IUSE=""
DEPEND="|| ( >=app-editors/vim-6.3
	>=app-editors/gvim-6.3 )"
RDEPEND="${DEPEND}"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
SLOT="0"

vim-plugin_src_install() {
	local f

	# we run unpriovileged
#	ebegin "Fixing file permissions"
#	# Make sure perms are good
#	chmod -R a+rX ${S} || die "chmod failed"
#	find ${S} -user  'portage' -exec chown root '{}' \; || die "chown failed"
#	if use userland_BSD || use userland_Darwin ; then
#		find ${S} -group 'portage' -exec chgrp wheel '{}' \; || die "chgrp failed"
#	else
#		find ${S} -group 'portage' -exec chgrp root '{}' \; || die "chgrp failed"
#	fi
#	eend $?

	# Install non-vim-help-docs
	cd ${S}
	for f in *; do
		[[ -f "${f}" ]] || continue
		if [[ "${f}" = *.html ]]; then
			dohtml "${f}"
		else
			dodoc "${f}"
		fi
		rm -f "${f}"
	done

	# Install remainder of plugin
	cd ${WORKDIR}
	dodir /usr/share/vim
	mv ${S} ${D}/usr/share/vim/vimfiles

	# Fix remaining bad permissions
	chmod -R -x+X ${D}/usr/share/vim/vimfiles/ || die "chmod failed"
}

vim-plugin_pkg_postinst() {
	update_vim_helptags		# from vim-doc
	update_vim_afterscripts	# see below
	display_vim_plugin_help	# see below
}

vim-plugin_pkg_postrm() {
	update_vim_helptags		# from vim-doc
	update_vim_afterscripts	# see below

	# Remove empty dirs; this allows
	# /usr/share/vim to be removed if vim-core is unmerged
	find ${EPREFIX}/usr/share/vim/vimfiles -depth -type d -exec rmdir {} \; 2>/dev/null
}

# update_vim_afterscripts: create scripts in
# /usr/share/vim/vimfiles/after/* comprised of the snippets in
# /usr/share/vim/vimfiles/after/*/*.d
update_vim_afterscripts() {
	local d f afterdir=${ROOT}/usr/share/vim/vimfiles/after

	# Nothing to do if the dir isn't there
	[ -d ${afterdir} ] || return 0

	einfo "Updating scripts in ${EPREFIX}/usr/share/vim/vimfiles/after"
	find ${afterdir} -type d -name \*.vim.d | \
	while read d; do
		echo '" Generated by update_vim_afterscripts' > "${d%.d}"
		find "${d}" -name \*.vim -type f -maxdepth 1 -print0 | \
		sort -z | xargs -0 cat >> "${d%.d}"
	done

	einfo "Removing dead scripts in ${EPREFIX}/usr/share/vim/vimfiles/after"
	find ${afterdir} -type f -name \*.vim | \
	while read f; do
		[[ "$(head -n 1 ${f})" == '" Generated by update_vim_afterscripts' ]] \
			|| continue
		# This is a generated file, but might be abandoned.  Check
		# if there's no corresponding .d directory, or if the
		# file's effectively empty
		if [[ ! -d "${f}.d" || -z "$(grep -v '^"')" ]]; then
			rm -f "${f}"
		fi
	done
}

# Display a message with the plugin's help file if one is available. Uses the
# VIM_PLUGIN_HELPFILES env var. If multiple help files are available, they
# should be separated by spaces. If no help files are available, but the env
# var VIM_PLUGIN_HELPTEXT is set, that is displayed instead. Finally, if we
# have nothing else, display a link to VIM_PLUGIN_HELPURI. An extra message
# regarding enabling filetype plugins is displayed if VIM_PLUGIN_MESSAGES
# includes the word "filetype".
display_vim_plugin_help() {
	local h

	if [[ -n "${VIM_PLUGIN_HELPFILES}" ]] ; then
		einfo " "
		einfo "This plugin provides documentation via vim's help system. To"
		einfo "view it, use:"
		for h in ${VIM_PLUGIN_HELPFILES} ; do
			einfo "    :help ${h}"
		done
		einfo " "

	elif [[ -n "${VIM_PLUGIN_HELPTEXT}" ]] ; then
		einfo " "
		while read h ; do
			einfo "$h"
		done <<<"${VIM_PLUGIN_HELPTEXT}"
		einfo " "

	elif [[ -n "${VIM_PLUGIN_HELPURI}" ]] ; then
		einfo " "
		einfo "Documentation for this plugin is available online at:"
		einfo "    ${VIM_PLUGIN_HELPURI}"
		einfo " "
	fi

	if hasq "filetype" "${VIM_PLUGIN_MESSAGES}" ; then
		einfo "This plugin makes use of filetype settings. To enable these,"
		einfo "add lines like:"
		einfo "    filetype plugin on"
		einfo "    filetype indent on"
		einfo "to your ~/.vimrc file."
		einfo " "
	fi
}

