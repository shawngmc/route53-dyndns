# Amazon Route53 Dynamic DNS Tool
A simple dynamic DNS service for Route53, now with docker swarm support!

## Retrieving your external IP
This service performs a DNS query to retrieve your IP address from an OpenDNS resolver. This method is arguably faster and more reliable than using an http(s) service.

Similar functionality could be done via the shell using dig: `dig +short myip.opendns.com @resolver1.opendns.com;`

## Docker Compose / Swarm Usage
```version: "3.5"
services:
    route53-dyndns:
        container_name: route53-dyndns
        deploy:
            restart_policy:
                condition: on-failure
                delay: 5s
                max_attempts: 3
                window: 120s
        environment:
            - 'AWS_CONNECTION_REGION=us-east-1'
            - 'ROUTE53_DOMAIN_A_RECORD=insert.your.domain.here'
            - 'ROUTE53_UPDATE_FREQUENCY=900'
        image: shawngmc/route53-dyndns
        secrets:
            - route53_access_key
            - route53_secret_key
secrets:
  route53_access_key:
    external:
      name: route53_access_key
  route53_secret_key:
    external:
      name: route53_secret_key
```

## CLI Usage
```bash
docker run -d \
    --name route53 \
    -e AWS_ACCESS_KEY_ID= \
    -e AWS_SECRET_ACCESS_KEY= \
    -e AWS_CONNECTION_REGION=us-east-1 \
    -e ROUTE53_DOMAIN_A_RECORD= insert.your.domain.here \
    -e ROUTE53_UPDATE_FREQUENCY=10800 \
    bshaw/route53-dyndns
```
## Required Secrets or Environment Variables
* `route53_access_key` - An AWS Access Key
* `route53_secret_key` - An AWS Secret Key

Note: The secrets will take precedence. If not using swarm mode, you can use environment variables - simply capitalize them. Secrets and swarm mode is HIGHLY recommended for security purposes.

## Required Environment Variables
* `AWS_CONNECTION_REGION` - The AWS region for connections
* `ROUTE53_DOMAIN_A_RECORD` - The A record to update, such as myhouse.domain.com
* `ROUTE53_UPDATE_FREQUENCY` - The frequency (in seconds) to check for updates. Unless you have very specific needs, consider using a very large value here.

## Credit
This is a fork of:
[bshaw/route53-dyndns](https://github.com/bshaw/route53-dyndns)
Heavily influenced by:
* [JacobSanford/docker-route53-dyndns](https://github.com/JacobSanford/docker-route53-dyndns)
* [JacobSanford/route-53-dyndns](https://github.com/JacobSanford/route-53-dyndns)
