#!/bin/sh

. /scripts/lib.subr

RUSTYPASTE_RANDOM_URL_TYPE="${RUSTYPASTE_RANDOM_URL_TYPE:-petname}"

if [ "${RUSTYPASTE_RANDOM_URL_TYPE}" = "petname" ]; then
	RUSTYPASTE_RANDOM_URL_WORDS="${RUSTYPASTE_RANDOM_URL_WORDS:-2}"
	RUSTYPASTE_RANDOM_URL_SEPARATOR="${RUSTYPASTE_RANDOM_URL_SEPARATOR:--}"

	info "Configuring paste.random_url.type -> ${RUSTYPASTE_RANDOM_URL_TYPE}"
	info "Configuring paste.random_url.words -> ${RUSTYPASTE_RANDOM_URL_WORDS}"
	info "Configuring paste.random_url.separator -> ${RUSTYPASTE_RANDOM_URL_SEPARATOR}"

	put -t string -v "${RUSTYPASTE_RANDOM_URL_TYPE}" paste.random_url.type
	put -t int -v "${RUSTYPASTE_RANDOM_URL_WORDS}" paste.random_url.words
	put -t string -v "${RUSTYPASTE_RANDOM_URL_SEPARATOR}" paste.random_url.separator
elif [ "${RUSTYPASTE_RANDOM_URL_TYPE}" = "alphanumeric" ]; then
	RUSTYPASTE_RANDOM_URL_LENGTH="${RUSTYPASTE_RANDOM_URL_LENGTH:-8}"

	info "Configuring paste.random_url.type -> ${RUSTYPASTE_RANDOM_URL_TYPE}"
	info "Configuring paste.random_url.length -> ${RUSTYPASTE_RANDOM_URL_LENGTH}"

	put -t string -v "${RUSTYPASTE_RANDOM_URL_TYPE}" paste.random_url.type
	put -t int -v "${RUSTYPASTE_RANDOM_URL_LENGTH}" paste.random_url.length
	if [ -n "${RUSTYPASTE_RANDOM_URL_SUFFIX_MODE}" ]; then
		info "Configuring paste.random_url.suffix_mode -> ${RUSTYPASTE_RANDOM_URL_SUFFIX_MODE}"
		put -t bool -v "${RUSTYPASTE_RANDOM_URL_SUFFIX_MODE}" paste.random_url.suffix_mode
	fi
elif [ "${RUSTYPASTE_RANDOM_URL_TYPE}" = "none" ]; then
	# Continue.
else
	err "paste.random.type only accepts 'petname', 'alphanumeric' and 'none'."
	exit 1
fi

if [ -n "${RUSTYPASTE_DEFAULT_EXTENSION}" ]; then
	info "Configuring paste.default_extension -> ${RUSTYPASTE_DEFAULT_EXTENSION}"
	put -t string -v "${RUSTYPASTE_DEFAULT_EXTENSION}" paste.default_extension
fi

# RUSTYPASTE_MIME_OVERRIDE_*
env | grep -Ee '^RUSTYPASTE_MIME_OVERRIDE_.+=.*$' | cut -d= -f2- | while IFS= read -r mime_override; do
	id = `select 'paste.mime_override.len()'` || exit $?

	mime = `printf "%s" "${mime_override}" | cut -d; -f1`
	regex = `printf "%s" "${mime_override}" | cut -d; -f2-`

	info "Configuring paste.mime_override.${id} -> mime:${mime}, regex:${regex}"

	if [ ${id} -eq 0 ]; then
		put -t string -v "${mime}" "paste.mime_override.[].mime"
	else
		put -t string -v "${mime}" "paste.mime_override.[${id}].mime"
	fi

	put -t string -v "${regex}" "paste.mime_override.[${id}].regex"
done

mime_override_len=`select 'paste.mime_override.len()'` || exit $?

# If empty, set defaults.
if [ ${mime_override_len} -eq 0 ]; then
	info "Configuring paste.mime_override.* (defaults) ..."

	# { mime = "image/jpeg", regex = "^.*\\.jpg$" },
	put -t string -v 'image/jpeg' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.jpg$' 'paste.mime_override.[0].regex'
	
	# { mime = "image/png", regex = "^.*\\.png$" },
	put -t string -v 'image/png' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.png$' 'paste.mime_override.[1].regex'
	
	# { mime = "image/svg+xml", regex = "^.*\\.svg$" },
	put -t string -v 'image/svg+xml' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.svg$' 'paste.mime_override.[2].regex'
	
	# { mime = "video/webm", regex = "^.*\\.webm$" },
	put -t string -v 'video/webm' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.webm$' 'paste.mime_override.[3].regex'
	
	# { mime = "video/x-matroska", regex = "^.*\\.mkv$" },
	put -t string -v 'video/x-matroska' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.mkv$' 'paste.mime_override.[4].regex'
	
	# { mime = "application/octet-stream", regex = "^.*\\.bin$" },
	put -t string -v 'application/octet-stream' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.bin$' 'paste.mime_override.[5].regex'
	
	# { mime = "text/plain", regex = "^.*\\.(log|txt|diff|sh|rs|toml)$" },
	put -t string -v 'text/plain' 'paste.mime_override.[].mime'
	put -t string -v '^.*\\.(log|txt|diff|sh|rs|toml)$' 'paste.mime_override.[6].regex'
fi

# RUSTYPASTE_MIME_BLACKLIST_*
mime_blacklist_count=0
env | grep -Ee '^RUSTYPASTE_MIME_BLACKLIST_.+=.*$' | cut -d= -f2- | while IFS= read -r mime_blacklist; do
	info "Configuring paste.mime_blacklist.${mime_blacklist_count} -> ${mime_blacklist}"
	put -t string -v "${mime_blacklist}" 'paste.mime_blacklist.[]'

	mime_blacklist_count=$((mime_blacklist_count+1))
done

mime_blacklist_count=`select 'paste.mime_blacklist.len()'` || exit $?

# If empty, set defaults.
if [ ${mime_blacklist_count} -eq 0 ]; then
	info "Configuring paste.mime_blacklist (defaults) ..."

	# "application/x-dosexec",
	put -t string -v "application/x-dosexec" 'paste.mime_blacklist.[]'

	# "application/java-archive",
	put -t string -v "application/java-archive" 'paste.mime_blacklist.[]'

	# "application/java-vm",
	put -t string -v "application/java-vm" 'paste.mime_blacklist.[]'
fi

if [ -n "${RUSTYPASTE_DUPLICATE_FILES}" ]; then
	info "Configuring paste.duplicate_files -> ${RUSTYPASTE_DUPLICATE_FILES}"
	put -t bool -v "${RUSTYPASTE_DUPLICATE_FILES}" paste.duplicate_files
fi

if [ -n "${RUSTYPASTE_DEFAULT_EXPIRY}" ]; then
	info "Configuring paste.default_expiry -> ${RUSTYPASTE_DEFAULT_EXPIRY}"
	put -t string -v "${RUSTYPASTE_DEFAULT_EXPIRY}" paste.default_expiry
fi

if [ -n "${RUSTYPASTE_DELETE_EXPIRED_FILES}" ]; then
	RUSTYPASTE_DELETE_INTERVAL="${RUSTYPASTE_DELETE_INTERVAL:-1h}"

	info "Configuring paste.delete_expired_files.enabled -> ${RUSTYPASTE_DELETE_EXPIRED_FILES}"
	info "Configuring paste.delete_expired_files.interval -> ${RUSTYPASTE_DELETE_INTERVAL}"

	put -t bool -v "${RUSTYPASTE_DELETE_EXPIRED_FILES}" paste.delete_expired_files.enabled
	put -t string -v "${RUSTYPASTE_DELETE_INTERVAL}" paste.delete_expired_files.interval
fi
