#!/bin/sh

NEKOBOX_CONFIG=/nekobox/nekobox.ini

function prtinfo() {
  echo "[INFO] $1"
}

function prterr() {
  echo -e "\e[0;31m[ERROR] $1\e[0m" >&2
}

####################################################
# Generate NekoBox configuration file if not exists.
# Globals:
#   NEKOBOX_UIN
#   NEKOBOX_SIGN_SERVER
#   NEKOBOX_PROTOCOL_TYPE
#   NEKOBOX_AUTH_TOKEN
#   NEKOBOX_BIND_ADDR
#   NEKOBOX_BIND_PORT
#   NEKOBOX_DEPLOY_PATH
#   NEKOBOX_LOG_LEVEL
####################################################
function genconf() {
  nekobox gen > /dev/null 2>&1 << ARGS
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
  if [ -z ${NEKOBOX_AUTH_TOKEN} ]; then
    prtinfo "Auth token has been randomly generated since it is not be \
explictly specified. You can check it in the 'nekobox.ini' config file or \
use 'nekobox show ${NEKOBOX_UIN}' command."
  fi
}

##########################################################################
# Read configurations of the specific user from the configuration file.
# Arguments:
#   A numeric string representing the user ID (uin).
# Outputs:
#   The key-value pairs of the user configuration. Key-value pairs are 
#   separated by an equals sign (`=`). Each pair is printed on a new line.
#   Nothing is printed if the user does not exist.
##########################################################################
function readconf() {
  awk -v target="$1" '
  BEGIN {
    in_section = 0
  }

  /^[[:space:]]*\[[[:space:]]*.*[[:space:]]*\][[:space:]]*$/ {
    current = $0
    gsub(/^[[:space:]]*\[|\][[:space:]]*$/, "", current)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", current)
    in_section = (current == target)
    next
  }

  in_section {
    sub(/[;#].*/, "")

    if (index($0, "=") > 0) {
      key = substr($0, 1, index($0, "=")-1)
      value = substr($0, index($0, "=")+1)

      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      if (key != "") {
        print key "=" value
      }
    }
  }
  ' ${NEKOBOX_CONFIG}
}

# TODO: Update configurations if changed.
# function is_conf_changed() {}

# Main process
if [ -z ${NEKOBOX_UIN} ]; then
  prterr "You must specify env 'NEKOBOX_UIN' to decide which account do you \
want to use."
  exit 1
fi

if [ -z ${NEKOBOX_SIGN_SERVER} ]; then
  prterr "You must provide a sign server address by specifying env \
'NEKOBOX_SIGN_SERVER'."
  exit 1
fi

if [ ! -f ${NEKOBOX_CONFIG} ]; then
  prtinfo "No config file found. Attempt to generate config from env..."
  genconf
elif ! nekobox show ${NEKOBOX_UIN}; then
  prtinfo "Specified UIN not found in the config file. Attempt to update \
config from env..."
  genconf
# TODO: Update configurations if changed.
# elif is_conf_changed ${NEKOBOX_UIN}; then
else
  prtinfo "Found proper config."
fi

prtinfo "Running NekoBox server..."
if [ "${NEKOBOX_FILE_QRCODE:-false}" = "true" ]; then
  prtinfo "Note: QR code will be saved as a file."
  nekobox run --file-qrcode ${NEKOBOX_UIN}
else
  nekobox run ${NEKOBOX_UIN}
fi
