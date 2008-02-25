#!/usr/bin/env bash

die() {
	echo "$*" > /dev/stderr
	rm -f /tmp/rqcommit.lock
	exit 1
}

if [[ ! -f eupdate.updates ]] ; then
	echo "cannot commit here, as there is no eupdate.updates file!" > /dev/stderr
	exit 1
fi

# synchronise the commits to be one at a time
lockfile /tmp/rqcommit.lock

ts=$(stat --format="%y" eupdate.updates)
rm eupdate.updates || die "failed to remove eupdate.updates"
ecleankw > /dev/null || die "failed to run ecleankw"
ekeyword *.ebuild > /dev/null || die "failed to run ekeyword"
repoman commit -m "$(<eupdate.msg) -- $dir ($ts)" >& /var/tmp/repoman.commit.$$ && rm /var/tmp/repoman.commit.$$ || mv /var/tmp/repoman.commit.$$ repoman.commit.failed
rm -f eupdate.msg || die "failed to remove eupdate.msg"

rm -f /tmp/rqcommit.lock
