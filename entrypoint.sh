#!/bin/sh

. /lib.subr

set -e

create_user

chown noroot:noroot /app
chown -R noroot:noroot /app/upload

exec su-exec noroot rustypaste "$@"
