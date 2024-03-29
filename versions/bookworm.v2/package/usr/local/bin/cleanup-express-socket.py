#!/usr/bin/env python3

import sys
import os
import logging
import pprint

from supervisor.childutils import listener


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
    debug_mode = os.environ.get('EXPRESS_DEBUG_CLEANUP', 'false').lower() == 'true'

    while True:
        logger.info("Listening for events...")
        headers, body = listener.wait(sys.stdin, sys.stdout)
        body = dict([pair.split(":") for pair in body.split(" ")])

        if debug_mode:
            logger.debug("Headers: %r", repr(headers))
            logger.debug("Body: %r", repr(body))
            logger.debug("Args: %r", repr(args))

        if debug_mode:
            ## Stops here, just show states
            listener.ok(sys.stdout)
            continue

        try:
            # logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
            # logger.info(pprint.pformat(headers))
            # logger.info(pprint.pformat(body))
            # logger.info("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

            is_event_stop_or_exit = headers["eventname"] in ["PROCESS_STATE_STOPPED", "PROCESS_STATE_EXITED"]
            is_express = 'groupname' in body and body['groupname'] == 'express'

            if is_event_stop_or_exit and is_express:
                if debug_mode:
                    logger.info("Process entered stop/exit state...")
                socket_file = os.environ['EXPRESS_SOCKET_FILE']
                if (socket_file and os.path.exists(socket_file) ):
                    os.remove(socket_file)
                    if debug_mode:
                        logger.info(f"Removed {socket_file} socket file")

        except Exception as e:
            logger.critical("Unexpected Exception: %s", str(e))
            listener.fail(sys.stdout)
            exit(1)
        else:
            listener.ok(sys.stdout)

if __name__ == '__main__':
    main(sys.argv[1:])
