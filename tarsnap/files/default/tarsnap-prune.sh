#!/bin/bash
# Remove old backups


. "$(dirname "$0")/tarsnap-env.sh"


# Using tail to find archives to delete, but its
# +n syntax is out by one from what we want to do
# (also +0 == +1, so we're safe :-)
DAILY=`expr $DAILY + 1`
WEEKLY=`expr $WEEKLY + 1`
MONTHLY=`expr $MONTHLY + 1`
DATETIME_REGEX="[[:digit:]]{8}-[[:digit:]]{6}"


TMPFILE=/tmp/tarsnap.archives.$$
$TARSNAP --list-archives > $TMPFILE


# Do deletes
for dir in $DIRS; do
    for i in `grep -E "^$DATETIME_REGEX-daily-$dir" $TMPFILE | sort -rn | tail -n +$DAILY`; do
        echo "==> delete $i"
        $TARSNAP -d -f $i
    done
    for i in `grep -E "^$DATETIME_REGEX-weekly-$dir" $TMPFILE | sort -rn | tail -n +$WEEKLY`; do
        echo "==> delete $i"
        $TARSNAP -d -f $i
    done
    for i in `grep -E "^$DATETIME_REGEX-monthly-$dir" $TMPFILE | sort -rn | tail -n +$MONTHLY`; do
        echo "==> delete $i"
        $TARSNAP -d -f $i
    done
done


# Look for unrecognized backups

echoerr() {
    echo "$@" 1>&2
}

WEIRD=$(grep -Ev "^$DATETIME_REGEX-(daily|weekly|monthly)-(<%= node[:tarsnap][:dirs].join('|') %>)" $TMPFILE)
if [ -n "$WEIRD" ]
then
    echoerr "Unrecognized backups found:"
    for i in $WEIRD
    do
        echoerr " - $i" >&2
    done
fi


rm $TMPFILE
