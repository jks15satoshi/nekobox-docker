ARG BASE_TAG=3.12-alpine
FROM python:${BASE_TAG}

ARG NEKOBOX_VERSION

ARG NEKOBOX_UNSTABLE
ENV NEKOBOX_UNSTABLE=${NEKOBOX_UNSTABLE:-false}

ARG NEKOBOX_EXTRA_DEPS=audio

RUN case $( grep "^ID=" /etc/os-release | awk -F= '{print $2}' ) in \
    "alpine") apk add --no-cache git ;; \
    "debian") apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/* ;; \
    *) echo "Unsupported OS" && exit 1 ;; \
    esac

RUN if [ -z "${NEKOBOX_EXTRA_DEPS}" ]; then \
    pkg="nekobox"; \
    else \
    pkg="nekobox[${NEKOBOX_EXTRA_DEPS}]"; \
    fi; \
    if [ "${NEKOBOX_UNSTABLE}" = true ]; then \
    pkg="${pkg} @ git+https://github.com/wyapx/nekobox.git@${NEKOBOX_VERSION:-main}"; \
    elif [ ! -z "${NEKOBOX_VERSION}" ]; then \
    pkg="${pkg}==${NEKOBOX_VERSION}"; \
    fi; \
    pip install --no-cache-dir "${pkg}"

RUN mkdir -p /nekobox
WORKDIR /nekobox

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/nekobox" ]

ENTRYPOINT [ "entrypoint.sh" ]
