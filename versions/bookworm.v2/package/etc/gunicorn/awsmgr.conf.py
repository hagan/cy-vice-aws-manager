# -*- encoding: utf-8 -*-
"""
Gunicorn configuration
"""
import pprint
import os
import multiprocessing
from dotenv import dotenv_values

pp = pprint.PrettyPrinter(indent=4)

# LOAD BEARER_TOKEN from /tmp/.env
# if (os.path.exists("/tmp/.env")):
#     config = dotenv_values("/tmp/.env")
# else:
#     raise Exception("Missing /tmp/.env file!")

# if 'BEARER_TOKEN' not in config:
#     raise Exception("Missing 'BEARER_TOKEN' in /tmp/.env!")
# else:
#     BEARER_TOKEN = config['BEARER_TOKEN']

# create local environment values out of any envprefixed wit GUNICORN_
for k,v in os.environ.items():
    if k.startswith("GUNICORN_"):
        key = k.split('_', 1)[1].lower()
        print(f"GUNICORN {key} = {v}")
        locals()[key] = v

## set write permissions to socket (group == www-data/nginx user)
umask = 0o002
if not 'bind' in locals():
    # bind = "0.0.0.0:8080"
    if 'socket_file' not in locals():
        raise Exception("Must set GUNICORN_SOCKET_FILE in environment!")
    else:
        print(f"binding to unix:{locals()['socket_file']}")
        bind = f"unix:{locals()['socket_file']}"

#spew = False if not 'spew' in locals() else (spew in ['true', 'True']))

forwarded_allowed_ips = "*" if not 'forwarded_allowed_ips' in locals() else "127.0.0.1"

worker_class = "gthread"
# worker_class = "sync"
if not 'workers' in locals():
    # workers = 4
    workers = 2

# calc_workers = multiprocessing.cpu_count() * 2 + 1
calc_workers = 2
print(f"if using standard equation for workers (cpu*2+1), we would have used {calc_workers}")

threads = 3

worker_tmp_dir = "/dev/shm"

umask = 0o007
# reload = True

access_log_format = '"%({X-REAL-IP}i)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
# syslog = True
# syslog_prefix = 'awsmgr:'
accesslog = "-"
errorlog = "-"
# raw_env = [
#     f"BEARER_TOKEN='{BEARER_TOKEN}'",
# ]