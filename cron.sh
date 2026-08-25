#!/usr/bin/env bash

## Legacy entry point: /etc/cron.d/zzmysqldump on pre-existing installs runs this script.
## New installs run bash-fx's cron-run.sh directly (see ./cron)
bash "/usr/local/turbolab.it/bash-fx/cron-run.sh" "zzmysqldump" "zzmysqldump.sh"
