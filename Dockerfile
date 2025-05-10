ARG BASE_TAG=3.12-alpine
FROM python:${BASE_TAG}

ARG NEKOBOX_VERSION
ARG NEKOBOX_DEVEL
ENV NEKOBOX_DEVEL=${NEKOBOX_DEVEL:-false}

RUN if [ "${NEKOBOX_DEVEL}" = true ]; then \
    pip install "git+https://github.com/wyapx/nekobox.git" \
    elif [ -z "${NEKOBOX_VERSION}" ]; then \
    pip install -U "nekobox[audio]"; \
    else \
    pip install "nekobox[audio]==${NEKOBOX_VERSION}"; \
    fi

RUN mkdir -p /nekobox
WORKDIR /nekobox

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/nekobox" ]

ENTRYPOINT [ "entrypoint.sh" ]
