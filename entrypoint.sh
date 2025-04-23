#!/bin/sh
NEKOBOX_CONFIG=/nekobox/nekobox.ini

# Print message with info level.
# Args:
#   $1: The message to print.
# Stdout:
#   The formatted message.
prtinfo() {
  printf "\e[0;34m[INFO]\e[0m %s\n" "$1"
}

# Print message with error level.
# Args:
#   $1: The message to print.
# Stderr:
#   The formatted message.
prterr() {
  printf "\e[0;31m[ERROR] %s\e[0m\n" "$1" >&2
}

# Calculate the digest of the configurations.
# Stdout:
#   The calculated digest.
digestconf() {
  printf "%s|" "${NEKOBOX_UIN}" \
    "${NEKOBOX_SIGN_SERVER}" \
    "${NEKOBOX_PROTOCOL_TYPE}" \
    "${NEKOBOX_AUTH_TOKEN}" \
    "${NEKOBOX_BIND_ADDR}" \
    "${NEKOBOX_BIND_PORT}" \
    "${NEKOBOX_DEPLOY_PATH}" \
    "${NEKOBOX_LOG_LEVEL}" |
    md5sum | cut -d ' ' -f 1
}

# Generate configuration file from environment variables.
#
# Digest will be calculated and saved as `.digests/${NEKOBOX_UIN}.md5`, used
# for checking whether the configuration file needs to be regenerated in the
# future.
genconf() {
  nekobox gen >/dev/null 2>&1 <<ARGS
${NEKOBOX_UIN}
${NEKOBOX_SIGN_SERVER}
${NEKOBOX_PROTOCOL_TYPE}
${NEKOBOX_AUTH_TOKEN}
${NEKOBOX_BIND_ADDR}
${NEKOBOX_BIND_PORT}
${NEKOBOX_DEPLOY_PATH}
${NEKOBOX_LOG_LEVEL}
ARGS

  prtinfo "Config file generated."
  if [ -z "${NEKOBOX_AUTH_TOKEN}" ]; then
    prtinfo "Auth token has been randomly generated since it is not be \
explicitly specified. You can check it in the 'nekobox.ini' config file or \
use 'nekobox show ${NEKOBOX_UIN}' command."
  fi

  mkdir -p .digests
  digestconf >".digests/${NEKOBOX_UIN}.md5"
  prtinfo "Digest calculated. Saved to '.digests/${NEKOBOX_UIN}.md5'."
}

# Main process
if [ -z "${NEKOBOX_UIN}" ]; then
  prterr "You must specify env 'NEKOBOX_UIN' to decide which account do you \
want to use."
  exit 1
fi

if [ -z "${NEKOBOX_SIGN_SERVER}" ]; then
  prterr "You must provide a sign server address by specifying env \
'NEKOBOX_SIGN_SERVER'."
  exit 1
fi

if [ ! -f ${NEKOBOX_CONFIG} ]; then
  prtinfo "No config file found. Attempt to generate config from env..."
  genconf
elif ! nekobox show "${NEKOBOX_UIN}" >/dev/null 2>&1; then
  prtinfo "Specified UIN not found in the config file. Attempt to update \
config from env..."
  genconf
elif [ ! -f ".digests/${NEKOBOX_UIN}.md5" ] ||
  [ "$(digestconf)" != "$(cat ".digests/${NEKOBOX_UIN}.md5")" ]; then
  prtinfo "Detected env config is different from the previous one. Attempt to \
update config from env..."
  genconf
else
  prtinfo "Found proper config."
fi

prtinfo "Running NekoBox server..."
if [ "${NEKOBOX_FILE_QRCODE:-false}" = "true" ]; then
  prtinfo "Note: QR code will be saved as a file."
  nekobox run --file-qrcode "${NEKOBOX_UIN}"
else
  nekobox run "${NEKOBOX_UIN}"
fi
