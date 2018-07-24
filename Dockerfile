FROM alpine:latest

RUN apk add --update \
        python \
        py-pip \
    && rm -rf /var/cache/apk/* \
    && pip install \
        boto \
        dnspython \
        get-docker-secret

COPY r53dyndns.py /usr/local/bin/r53dyndns.py
COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
