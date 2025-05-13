ARG BASE_TAG=3.12-alpine
FROM python:${BASE_TAG}

ARG NEKOBOX_VERSION

ARG NEKOBOX_UNSTABLE
ENV NEKOBOX_UNSTABLE=${NEKOBOX_UNSTABLE:-false}

ARG NEKOBOX_EXTRA_DEPS=audio

RUN apk add --no-cache git

RUN if [ -z "${NEKOBOX_EXTRA_DEPS}" ]; then \
    pkg="nekobox"; \
    else \
    pkg="nekobox[${NEKOBOX_EXTRA_DEPS}]"; \
    fi; \
    if [ "${NEKOBOX_UNSTABLE}" = true ]; then \
    pkg="${pkg} @ git+https://github.com/wyapx/nekobox.git@${NEKOBOX_VERSION:-main}"; \
    elif [ -z "${NEKOBOX_VERSION}" ]; then \
    pkg="${pkg}==${NEKOBOX_VERSION}}"; \
    fi; \
    pip install "${pkg}"

RUN mkdir -p /nekobox
WORKDIR /nekobox

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/nekobox" ]

ENTRYPOINT [ "entrypoint.sh" ]
