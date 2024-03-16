#!/usr/local/bin/python3

import sys
import os
import logging
import pprint

from supervisor.childutils import listener
from pymemcache.client.base import Client

DEFAULT_DURATION=1800
DEBUG_THIS = False
debug_print = lambda s: write_stderr(s) if DEBUG_THIS is True else None


def memcached_check_available():
    debug_print("memcached_check_available()")
    client = Client(('localhost', 11212))
    try:
        client.set('awsmgr_test_key_is_running', True)
        value = client.get('awsmgr_test_key_is_running')
        client.close()
    except Exception as e:
        return False
    return value


def memcached_get(key: str) -> int | str | dict:
    """
    Retrieves key from memcached
    """
    debug_print("memcached_get()")
    client = Client(('localhost', 11212))
    try:
        value = client.get(key)
        client.close()
    except Exception as e:
        return None
    return value


def memcached_set(key: str, value: int | str | dict, expire: int = 0) -> None:
    """
    Sets a value with a key in memcached
    """
    debug_print(f"memcached_set({key})")
    client = Client(('localhost', 11212))
    value = client.set(key, value, expire=expire)
    client.close()


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
    has_ran = False
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

        # try:
        is_event_starting = body['from_state'] in ["STARTING"]
        is_memcached = 'processname' in body and body['processname'] == 'memcached'

        credentials = {
            'aws_access_key_id': None,
            'aws_secret_access_key': None,
            'aws_session_token': None,
        }

        if is_event_starting and is_memcached and not has_ran:
            has_ran = True
            # logger.info("vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvMEMCACHEDvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv")
            # logger.info(pprint.pformat(headers))
            # logger.info(pprint.pformat(body))
            # logger.info("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^MEMCACHED^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            env_vars = {
                'AWS_ACCOUNT_ID': 0,
                'AWS_ACCESS_KEY_ID': DEFAULT_DURATION-5,
                'AWS_SECRET_ACCESS_KEY': DEFAULT_DURATION-5,
                'AWS_SESSION_TOKEN': DEFAULT_DURATION-5,
                'AWS_DEFAULT_REGION': 0,
                'AWS_CREDENTIAL_EXPIRATION': DEFAULT_DURATION-5
            }
            required_var = [
                'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_SESSION_TOKEN'
            ]

            logger.info(f"Loading {', '.join(env_vars)} from environment into memcached")
            for env_var, dur in env_vars.items():
                _tmp = os.environ.get(env_var, None)
                if _tmp:
                    # Client(('localhost', 11212)).set(env_var, _tmp, expire=dur)
                    memcached_set(env_var, _tmp, expire=dur)
                    if(env_var in required_var):
                        credentials[env_var.lower()] = _tmp
                elif((not _tmp) and (env_var == 'AWS_ACCOUNT_ID')):
                    debug_print("WARNING: Failed to fetch user's account id!")
                elif((not _tmp) and (env_var in required_var)):
                    raise Exception(f"'{env_var}' is a required environment variable!")

        # except Exception as e:
        #     logger.critical("Unexpected Exception: %s", str(e))
        #     listener.fail(sys.stdout)
        #     exit(1)
        # else:
        listener.ok(sys.stdout)


if __name__ == '__main__':
    main(sys.argv[1:])
