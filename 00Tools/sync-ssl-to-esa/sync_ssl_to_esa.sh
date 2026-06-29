#!/usr/bin/env sh
set -eu

# Pull a TLS certificate from an HTTP endpoint and optionally upload it to
# Alibaba Cloud ESA as a custom uploaded site certificate.
#
# Required tools:
#   curl
# Optional tools:
#   openssl  - validates cert/key and prints expiry
#   aliyun   - required only when ESA_PUSH=1
#
# Common usage:
#   sudo sh sync_ssl_to_esa.sh
#
# Push to ESA after pulling:
#   sudo ESA_PUSH=1 ALIYUN_ESA_SITE_ID=1234567890123 sh sync_ssl_to_esa.sh
#
# Configure source filenames exposed by the HTTP directory listing:
#   sudo SOURCE_CERT_FILE=ggit.cc.pem SOURCE_KEY_FILE=ggit.cc.key sh sync_ssl_to_esa.sh
#
# By default the files are stored with the same names under SSL_DIR:
#   /etc/configs/nginx/ssl/ggit.cc.pem
#   /etc/configs/nginx/ssl/ggit.cc.key
#
# Optional config file:
#   /etc/sync-ssl-to-esa.env
#
# Or specify exact URLs:
#   sudo CERT_URL=http://192.168.112.1:16602/ggit.cc.pem \
#        KEY_URL=http://192.168.112.1:16602/ggit.cc.key \
#        sh sync_ssl_to_esa.sh

CONFIG_FILE="${SYNC_SSL_CONFIG:-/etc/sync-ssl-to-esa.env}"
if [ -f "$CONFIG_FILE" ]; then
  # shellcheck disable=SC1090
  . "$CONFIG_FILE"
fi

SOURCE_BASE_URL="${SOURCE_BASE_URL:-http://192.168.112.1:16602/}"
SOURCE_USER="${SOURCE_USER:-admin}"
SOURCE_PASS="${SOURCE_PASS:-admin}"
SOURCE_INSECURE="${SOURCE_INSECURE:-0}"
SOURCE_CERT_FILE="${SOURCE_CERT_FILE:-ggit.cc.pem}"
SOURCE_KEY_FILE="${SOURCE_KEY_FILE:-ggit.cc.key}"

SSL_DIR="${SSL_DIR:-/etc/configs/nginx/ssl}"
OUTPUT_CERT_NAME="${OUTPUT_CERT_NAME:-$(basename "$SOURCE_CERT_FILE")}"
OUTPUT_KEY_NAME="${OUTPUT_KEY_NAME:-$(basename "$SOURCE_KEY_FILE")}"
CERT_FILE="${CERT_FILE:-$SSL_DIR/$OUTPUT_CERT_NAME}"
KEY_FILE="${KEY_FILE:-$SSL_DIR/$OUTPUT_KEY_NAME}"

CERT_URL="${CERT_URL:-${FULLCHAIN_URL:-}}"
KEY_URL="${KEY_URL:-${PRIVATE_KEY_URL:-}}"

CERT_PATHS="${CERT_PATHS:-$SOURCE_CERT_FILE fullchain.pem cert.pem certificate.pem certificate.crt ssl/fullchain.pem ssl/cert.pem ssl/certificate.pem ssl/certificate.crt}"
KEY_PATHS="${KEY_PATHS:-$SOURCE_KEY_FILE privkey.pem private.key key.pem certificate.key ssl/privkey.pem ssl/private.key ssl/key.pem ssl/certificate.key}"

CURL_RETRY="${CURL_RETRY:-3}"
CURL_CONNECT_TIMEOUT="${CURL_CONNECT_TIMEOUT:-10}"
CURL_MAX_TIME="${CURL_MAX_TIME:-60}"

ESA_PUSH="${ESA_PUSH:-0}"
ALIYUN_ESA_SITE_ID="${ALIYUN_ESA_SITE_ID:-1098350467844576}"
ALIYUN_ESA_CERT_NAME="${ALIYUN_ESA_CERT_NAME:-nginx-$(date +%Y%m%d-%H%M%S)}"
ALIYUN_ESA_ENDPOINT="${ALIYUN_ESA_ENDPOINT:-esa.cn-hangzhou.aliyuncs.com}"
ALIYUN_ESA_VERSION="${ALIYUN_ESA_VERSION:-2024-09-10}"
ALIYUN_ESA_API_NAME="${ALIYUN_ESA_API_NAME:-}"
ALIYUN_PROFILE="${ALIYUN_PROFILE:-}"

NGINX_RELOAD_CMD="${NGINX_RELOAD_CMD:-}"

log() {
  printf '%s %s\n' "[$(date '+%Y-%m-%d %H:%M:%S')]" "$*"
}

die() {
  log "ERROR: $*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

join_url() {
  base=$1
  path=$2

  case "$path" in
    http://*|https://*)
      printf '%s\n' "$path"
      ;;
    /*)
      printf '%s%s\n' "$(printf '%s' "$base" | sed 's:/*$::')" "$path"
      ;;
    *)
      printf '%s/%s\n' "$(printf '%s' "$base" | sed 's:/*$::')" "$path"
      ;;
  esac
}

curl_get() {
  curl_url=$1
  curl_output=$2

  curl_args="-fsSL --retry $CURL_RETRY --connect-timeout $CURL_CONNECT_TIMEOUT --max-time $CURL_MAX_TIME"
  if [ "$SOURCE_INSECURE" = "1" ]; then
    curl_args="$curl_args -k"
  fi

  if [ -n "$SOURCE_USER" ]; then
    # shellcheck disable=SC2086
    curl $curl_args -u "$SOURCE_USER:$SOURCE_PASS" "$curl_url" -o "$curl_output"
  else
    # shellcheck disable=SC2086
    curl $curl_args "$curl_url" -o "$curl_output"
  fi
}

looks_like_cert() {
  grep -q -- "-----BEGIN CERTIFICATE-----" "$1"
}

looks_like_key() {
  grep -Eq -- "-----BEGIN (RSA |EC |OPENSSH |ENCRYPTED )?PRIVATE KEY-----" "$1"
}

fetch_first_match() {
  fetch_kind=$1
  fetch_paths=$2
  fetch_output=$3
  fetch_index=0

  for fetch_path in $fetch_paths; do
    fetch_url=$(join_url "$SOURCE_BASE_URL" "$fetch_path")
    fetch_index=$((fetch_index + 1))
    fetch_tmp="$TMP_DIR/${fetch_kind}.${fetch_index}.$$.download"

    log "Trying $fetch_kind: $fetch_url"
    if curl_get "$fetch_url" "$fetch_tmp"; then
      if [ "$fetch_kind" = "certificate" ] && looks_like_cert "$fetch_tmp"; then
        cp "$fetch_tmp" "$fetch_output"
        log "Fetched certificate from $fetch_url"
        return 0
      fi

      if [ "$fetch_kind" = "private-key" ] && looks_like_key "$fetch_tmp"; then
        cp "$fetch_tmp" "$fetch_output"
        log "Fetched private key from $fetch_url"
        return 0
      fi
    fi

    rm -f "$fetch_tmp"
  done

  return 1
}

fetch_exact() {
  kind=$1
  url=$2
  output=$3

  log "Fetching $kind: $url"
  curl_get "$url" "$output"

  if [ "$kind" = "certificate" ]; then
    looks_like_cert "$output" || die "downloaded certificate does not look like a PEM certificate: $url"
  else
    looks_like_key "$output" || die "downloaded private key does not look like a PEM private key: $url"
  fi
}

validate_pair() {
  if ! command -v openssl >/dev/null 2>&1; then
    log "openssl not found, skipped cert/key validation"
    return 0
  fi

  cert_pub="$TMP_DIR/cert.pub.sha256"
  key_pub="$TMP_DIR/key.pub.sha256"

  openssl x509 -in "$1" -noout -pubkey 2>/dev/null | openssl sha256 > "$cert_pub" \
    || die "failed to parse certificate with openssl"
  openssl pkey -in "$2" -pubout 2>/dev/null | openssl sha256 > "$key_pub" \
    || die "failed to parse private key with openssl"

  cmp -s "$cert_pub" "$key_pub" || die "certificate and private key do not match"

  expiry=$(openssl x509 -in "$1" -noout -enddate 2>/dev/null | sed 's/^notAfter=//')
  log "Certificate/key validated. Not after: $expiry"
}

install_files() {
  mkdir -p "$SSL_DIR"
  chmod 700 "$SSL_DIR" 2>/dev/null || true

  cp "$1" "$CERT_FILE"
  cp "$2" "$KEY_FILE"
  chmod 600 "$CERT_FILE" "$KEY_FILE" 2>/dev/null || true

  log "Installed certificate: $CERT_FILE"
  log "Installed private key: $KEY_FILE"
}

reload_nginx_if_requested() {
  if [ -z "$NGINX_RELOAD_CMD" ]; then
    return 0
  fi

  log "Running reload command: $NGINX_RELOAD_CMD"
  sh -c "$NGINX_RELOAD_CMD"
}

push_to_esa() {
  [ "$ESA_PUSH" = "1" ] || return 0

  need_cmd aliyun
  [ -n "$ALIYUN_ESA_SITE_ID" ] || die "ESA_PUSH=1 requires ALIYUN_ESA_SITE_ID"

  cert_content=$(cat "$CERT_FILE")
  key_content=$(cat "$KEY_FILE")
  api_name=$ALIYUN_ESA_API_NAME

  if [ -z "$api_name" ]; then
    if aliyun esa help 2>/dev/null | grep -q 'set-certificate'; then
      api_name=set-certificate
    else
      api_name=SetCertificate
    fi
  fi

  log "Uploading certificate to Alibaba Cloud ESA site $ALIYUN_ESA_SITE_ID"

  if [ -n "$ALIYUN_PROFILE" ]; then
    aliyun esa "$api_name" \
      --SiteId "$ALIYUN_ESA_SITE_ID" \
      --Name "$ALIYUN_ESA_CERT_NAME" \
      --Type upload \
      --Certificate "$cert_content" \
      --PrivateKey "$key_content" \
      --version "$ALIYUN_ESA_VERSION" \
      --endpoint "$ALIYUN_ESA_ENDPOINT" \
      --profile "$ALIYUN_PROFILE" \
      --force
  else
    aliyun esa "$api_name" \
      --SiteId "$ALIYUN_ESA_SITE_ID" \
      --Name "$ALIYUN_ESA_CERT_NAME" \
      --Type upload \
      --Certificate "$cert_content" \
      --PrivateKey "$key_content" \
      --version "$ALIYUN_ESA_VERSION" \
      --endpoint "$ALIYUN_ESA_ENDPOINT" \
      --force
  fi

  log "ESA upload completed"
}

main() {
  need_cmd curl

  TMP_DIR=$(mktemp -d)
  export TMP_DIR
  trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

  tmp_cert="$TMP_DIR/fullchain.pem"
  tmp_key="$TMP_DIR/privkey.pem"

  if [ -n "$CERT_URL" ]; then
    fetch_exact certificate "$CERT_URL" "$tmp_cert"
  else
    fetch_first_match certificate "$CERT_PATHS" "$tmp_cert" \
      || die "failed to find certificate. Set CERT_URL or CERT_PATHS."
  fi
  [ -s "$tmp_cert" ] || die "certificate file was not created: $tmp_cert"

  if [ -n "$KEY_URL" ]; then
    fetch_exact private-key "$KEY_URL" "$tmp_key"
  else
    fetch_first_match private-key "$KEY_PATHS" "$tmp_key" \
      || die "failed to find private key. Set KEY_URL or KEY_PATHS."
  fi
  [ -s "$tmp_key" ] || die "private key file was not created: $tmp_key"

  validate_pair "$tmp_cert" "$tmp_key"
  install_files "$tmp_cert" "$tmp_key"
  reload_nginx_if_requested
  push_to_esa

  log "Done"
}

main "$@"
