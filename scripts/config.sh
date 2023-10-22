#!/bin/sh

. /scripts/lib.subr

if [ -n "${RUSTYPASTE_REFRESH_RATE}" ]; then
	info "Configuring config.refresh_rate -> ${RUSTYPASTE_REFRESH_RATE}"
	put -t string -v "${RUSTYPASTE_REFRESH_RATE}" config.refresh_rate
fi
