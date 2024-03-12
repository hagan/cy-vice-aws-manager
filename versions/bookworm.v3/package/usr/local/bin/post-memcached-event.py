#!/usr/local/bin/python3

import sys
import os
import logging
import pprint

from supervisor.childutils import listener
from pymemcache.client.base import Client

DEFAULT_DURATION=1800


def write_stdout(s):
    # only eventlistener protocol messages may be sent to stdout
    sys.stdout.write(s)
    sys.stdout.flush()


def write_stderr(s):
    sys.stderr.write(s)
    sys.stderr.flush()


def main(args):
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG, format='%(asctime)s %(levelname)s %(filename)s: %(message)s')
    logger = logging.getLogger("supervisord-watchdog")
    debug_mode = os.environ.get('MEMCACHED_EVENT_DEBUG', 'false').lower() == 'true'
    while True:
        logger.info("Listening for events...")
        headers, body = listener.wait(sys.stdin, sys.stdout)
        body = dict([pair.split(":") for pair in body.split(" ")])

        if debug_mode:
            logger.debug("Headers: %r", repr(headers))
            logger.debug("Body: %r", repr(body))
            logger.debug("Args: %r", repr(args))
            ## Stops here, just show states
            listener.ok(sys.stdout)
            continue

        try:
            is_event_starting = body['from_state'] in ["STARTING"]
            is_memcached = 'processname' in body and body['processname'] == 'memcached'

            if is_event_starting and is_memcached:
                # logger.info("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvMEMCACHEDvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
                # logger.info(pprint.pformat(headers))
                # logger.info(pprint.pformat(body))
                # logger.info("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^MEMCACHED^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
                aaki = os.environ.get('AWS_ACCESS_KEY_ID', None)
                if aaki is not None:
                    Client(('localhost', 11212)).set('AWS_ACCESS_KEY_ID', aaki, expire=DEFAULT_DURATION-5)

                asak = os.environ.get('AWS_SECRET_ACCESS_KEY', None)
                if asak is not None:
                    Client(('localhost', 11212)).set('AWS_SECRET_ACCESS_KEY', asak, expire=DEFAULT_DURATION-5)

                ast = os.environ.get('AWS_SESSION_TOKEN', None)
                if ast is not None:
                    Client(('localhost', 11212)).set('AWS_SESSION_TOKEN', ast, expire=DEFAULT_DURATION-5)

                akk = os.environ.get('AWS_KMS_KEY', None)
                if akk is not None:
                    Client(('localhost', 11212)).set('AWS_KMS_KEY', akk, expire=0)

                ar = os.environ.get('AWS_REGION', None)
                if ar is not None:
                    Client(('localhost', 11212)).set('AWS_REGION', ar, expire=0)

                ap = os.environ.get('AWS_PROFILE', None)
                if ap is not None:
                    Client(('localhost', 11212)).set('AWS_PROFILE', ap, expire=0)



        except Exception as e:
            logger.critical("Unexpected Exception: %s", str(e))
            listener.fail(sys.stdout)
            exit(1)
        else:
            listener.ok(sys.stdout)

        # # transition from ACKNOWLEDGED to READY
        # write_stdout('READY\n')

        # # read header line and print it to stderr
        # line = sys.stdin.readline()
        # write_stderr(line)

        # # read event payload and print it to stderr
        # headers = dict([ x.split(':') for x in line.split() ])
        # data = sys.stdin.read(int(headers['len']))
        # write_stderr(data)

        # # transition from READY to ACKNOWLEDGED
        # write_stdout('RESULT 2\nOK')

if __name__ == '__main__':
    main(sys.argv[1:])
