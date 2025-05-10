ARG BASE_TAG=3.12-alpine
FROM python:${BASE_TAG}

ARG NEKOBOX_VERSION

ARG NEKOBOX_UNSTABLE
ENV NEKOBOX_UNSTABLE=${NEKOBOX_UNSTABLE:-false}

ARG NEKOBOX_OPTIONAL_DEPS=audio

RUN if [ "${NEKOBOX_UNSTABLE}" = true ]; then \
    pip install "git+https://github.com/wyapx/nekobox.git"; \
    else \
    if [ -z "${NEKOBOX_OPTIONAL_DEPS}" ]; then \
    nekobox="nekobox"; \
    else \
    nekobox="nekobox[${NEKOBOX_OPTIONAL_DEPS}]"; \
    fi; \
    if [ -z "${NEKOBOX_VERSION}" ]; then \
    pip install -U "${nekobox}"; \
    else \
    pip install "${nekobox}==${NEKOBOX_VERSION}"; \
    fi; \
    fi

RUN mkdir -p /nekobox
WORKDIR /nekobox

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/nekobox" ]

ENTRYPOINT [ "entrypoint.sh" ]
