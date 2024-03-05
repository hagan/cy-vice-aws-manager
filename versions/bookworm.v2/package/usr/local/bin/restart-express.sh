#!/usr/bin/env bash

supervisorctl reread; supervisorctl update; supervisorctl stop express; supervisorctl start express