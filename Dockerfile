ARG base_tag=3.12-alpine
FROM python:${base_tag}

ARG version
RUN if [ -z "${version}" ]; then \
    pip install -U "nekobox[audio]"; \
    else \
    pip install "nekobox[audio]==${version}"; \
    fi

RUN mkdir -p /nekobox
WORKDIR /nekobox

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME [ "/nekobox" ]

ENTRYPOINT [ "entrypoint.sh" ]
