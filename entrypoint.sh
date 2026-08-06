#!/bin/sh

. /lib.subr

set -e

create_user

chown noroot:noroot /app
change_owner /app/upload

exec su-exec noroot rustypaste "$@"
