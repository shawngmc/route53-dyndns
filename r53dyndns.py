#! /usr/bin/env python
"""Updates a Route53 hosted A alias record with the current ip of the system.
"""
import dns.resolver
from get_docker_secret import get_docker_secret
import boto.route53
import logging
from optparse import OptionParser
from re import search
import socket
import sys
import time

parser = OptionParser()
parser.add_option('-R', '--record', type='string', dest='record_to_update', help='The A record to update.')
parser.add_option('-v', '--verbose', dest='verbose', default=False, help='Enable Verbose Output.', action='store_true')
parser.add_option('-t', '--time', dest='time', default=30, type='int', help='Time between checks.')
(options, args) = parser.parse_args()

if options.record_to_update is None:
    logging.error('Please specify an A record with the -R switch.')
    parser.print_help()
    sys.exit(-1)
if options.verbose:
    logging.basicConfig(
        level=logging.INFO,
    )

def checkIPChange():
    # get external ip
    resolver = dns.resolver.Resolver()
    resolver.nameservers=[socket.gethostbyname('resolver1.opendns.com')]
    for rdata in resolver.query('myip.opendns.com', 'A') :
        current_ip = str(rdata)
        logging.info('Current IP address: %s', current_ip)

    record_to_update = options.record_to_update
    zone_to_update = '.'.join(record_to_update.split('.')[-2:])

    try:
        socket.inet_aton(current_ip)
        access_key = get_docker_secret('route53_access_key')
        secret_key = get_docker_secret('route53_secret_key')
        conn = boto.route53.Route53Connection(access_key, secret_key)
        zone = conn.get_zone(zone_to_update)
        for record in zone.get_records():
            if search(r'<Record:' + record_to_update, str(record)):
                if current_ip in record.to_print():
                    logging.info('Record IP matches, doing nothing.')
                else:
                    logging.info('IP does not match, update needed.')
                    zone.delete_a(record_to_update)
                    zone.add_a(record_to_update, current_ip)
        logging.info('Record not found, add needed')
        zone.add_a(record_to_update, current_ip)
    except socket.error as e:
        logging.error(repr(e))

def cronLoop():
    while True:
        checkIPChange()
        logging.info('Waiting %s...' % options.time)
        time.sleep(options.time)
 
try:
    cronLoop()
except KeyboardInterrupt:
    logging.error('\n\nKeyboard exception received. Exiting.')
    exit()
