#!/bin/sh

. /scripts/lib.subr

if [ -n "${RUSTYPASTE_ADDRESS}" ]; then
	info "Configuring server.address -> ${RUSTYPASTE_ADDRESS}"
	put -t string -v "${RUSTYPASTE_ADDRESS}" server.address
fi

if [ -n "${RUSTYPASTE_URL}" ]; then
	info "Configuring server.url -> ${RUSTYPASTE_URL}"
	put -t string -v "${RUSTYPASTE_URL}" server.url
fi

if [ -n "${RUSTYPASTE_WORKERS}" ]; then
	info "Configuring server.workers (manual) -> ${RUSTYPASTE_WORKERS}"
else
	export RUSTYPASTE_WORKERS=`sysctl -n hw.ncpu`

	info "Configuring server.workers (auto) -> ${RUSTYPASTE_WORKERS}"
fi

put -t int -v "${RUSTYPASTE_WORKERS}" server.workers

if [ -n "${RUSTYPASTE_MAX_CONTENT_LENGTH}" ]; then
	info "Configuring server.max_content_length -> ${RUSTYPASTE_MAX_CONTENT_LENGTH}"
	put -t string -v "${RUSTYPASTE_MAX_CONTENT_LENGTH}" server.max_content_length
fi

if [ -n "${RUSTYPASTE_UPLOAD_PATH}" ]; then
	info "Configuring server.upload_path -> ${RUSTYPASTE_UPLOAD_PATH}"
	put -t string -v "${RUSTYPASTE_UPLOAD_PATH}" server.upload_path
fi

if [ -n "${RUSTYPASTE_TIMEOUT}" ]; then
	info "Configuring server.timeout -> ${RUSTYPASTE_TIMEOUT}"
	put -t string -v "${RUSTYPASTE_TIMEOUT}" server.timeout
fi

if [ -n "${RUSTYPASTE_EXPOSE_VERSION}" ]; then
	info "Configuring server.expose_version -> ${RUSTYPASTE_EXPOSE_VERSION}"
	put -t bool -v "${RUSTYPASTE_EXPOSE_VERSION}" server.expose_version
fi

if [ -n "${RUSTYPASTE_EXPOSE_LIST}" ]; then
	info "Configuring server.expose_list -> ${RUSTYPASTE_EXPOSE_LIST}"
	put -t bool -v "${RUSTYPASTE_EXPOSE_LIST}" server.expose_list
fi

# RUSTYPASTE_AUTH_TOKENS_*
token_count=0
env | grep -Ee '^RUSTYPASTE_AUTH_TOKENS_.+=.*$' | cut -d= -f2- | while IFS= read -r token; do
	info "Configuring server.auth_tokens.${token_count} -> ${token}"
	put -t string -v "${token}" 'server.auth_tokens.[]'

	token_count=$((token_count+1))
done

# RUSTYPASTE_DELETE_TOKENS_*
token_count=0
env | grep -Ee '^RUSTYPASTE_DELETE_TOKENS_.+=.*$' | cut -d= -f2- | while IFS= read -r token; do
	info "Configuring server.delete_tokens.${token_count} -> ${token}"
	put -t string -v "${token}" 'server.delete_tokens.[]'

	token_count=$((token_count+1))
done

if [ -n "${RUSTYPASTE_HANDLE_SPACES}" ]; then
	if [ "${RUSTYPASTE_HANDLE_SPACES}" != "replace" -a "${RUSTYPASTE_HANDLE_SPACES}" != "encode" ]; then
		err "server.handle_spaces only accepts 'replace' and 'encode'."
		exit 1
	fi

	info "Configuring server.handle_spaces -> ${RUSTYPASTE_HANDLE_SPACES}"
	put -t string -v "${RUSTYPASTE_HANDLE_SPACES}" server.handle_spaces
fi
