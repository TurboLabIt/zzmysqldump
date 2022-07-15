#!/usr/bin/env bash
echo ""
SCRIPT_NAME=zzmysqldump

## bash-fx
sudo apt update && sudo apt install curl -y
curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/master/setup.sh?$(date +%s) | sudo bash
source /usr/local/turbolab.it/bash-fx/bash-fx.sh
## bash-fx is ready

sudo bash /usr/local/turbolab.it/bash-fx/setup/start.sh ${SCRIPT_NAME}
sudo apt install git mysql-client p7zip-full -y
fxLinkBin ${INSTALL_DIR}${SCRIPT_NAME}.sh
fxLinkBin ${INSTALL_DIR}zzmysqlimp.sh

if [ ! -f "/etc/cron.d/zzmysqldump" ]; then
  sudo cp "${INSTALL_DIR}cron" "/etc/cron.d/zzmysqldump"
fi

sudo bash /usr/local/turbolab.it/bash-fx/setup/the-end.sh ${SCRIPT_NAME}
