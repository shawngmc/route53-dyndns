FROM alpine:latest

LABEL maintainer="shawngmc@gmail.com"
LABEL forked-from="bshaw/route53-dyndns"

LABEL org.label-schema.build-date="2019-07-11T15:36:00.00Z"
LABEL org.label-schema.name = "route53-dyndns"
LABEL org.label-schema.description = "A docker image to update a route 53 domain with the current IP on a regular basis"
LABEL org.label-schema.url="https://github.com/shawngmc/route53-dyndns"
LABEL org.label-schema.vcs-url="https://github.com/shawngmc/route53-dyndns"
LABEL org.label-schema.vendor = "Shawn McNaughton"
LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.version = "1.1"

RUN apk add --update \
        python \
        py-pip \
        procps \
    && rm -rf /var/cache/apk/* \
    && pip install \
        boto \
        dnspython \
        get-docker-secret

RUN addgroup aws \
    && adduser -D -G aws awsuser
USER awsuser

COPY r53dyndns.py /usr/local/bin/r53dyndns.py
COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=1 CMD [ "/usr/bin/pgrep r53dyndns.py" ]
