FROM alpine:3.8

LABEL maintainer="shawngmc@gmail.com"
LABEL forked-from="bshaw/route53-dyndns"

LABEL org.label-schema.build-date="2018-07-24T18:35:00.00Z"
LABEL org.label-schema.name = "route53-dyndns"
LABEL org.label-schema.description = "A docker image to update a route 53 domain with the current IP on a regular basis"
LABEL org.label-schema.url="https://github.com/shawngmc/route53-dyndns"
LABEL org.label-schema.vcs-url="https://github.com/shawngmc/route53-dyndns"
LABEL org.label-schema.vendor = "Shawn McNaughton"
LABEL org.label-schema.schema-version = "1.0"
LABEL org.label-schema.version = "1.02"

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
