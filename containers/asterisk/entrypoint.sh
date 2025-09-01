#!/bin/sh
set -e
: "${GREETING:=Hello}"
: "${TARGET:=World}"
echo "${GREETING}, ${TARGET}! ($(date -Iseconds)) from $HOSTNAME"
