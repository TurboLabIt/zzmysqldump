#!/bin/bash
clear

## Script name
SCRIPT_NAME=zzmysqldump

## Pre-requisites
apt update
apt install git mysql-client p7zip-full -y

## Install directory
INSTALL_DIR_PARENT="/usr/local/turbolab.it/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/

## /etc/ config directory
mkdir -p "/etc/turbolab.it/"

## Install/update
echo ""
if [ ! -d "$INSTALL_DIR" ]; then
	echo "Installing..."
	echo "-------------"
	mkdir -p "$INSTALL_DIR_PARENT"
	git -C "$INSTALL_DIR_PARENT" clone https://github.com/TurboLabIt/${SCRIPT_NAME}.git
else
	echo "Updating..."
	echo "----------"
fi

## Fetch & pull new code
git -C "$INSTALL_DIR" fetch origin
git -C "$INSTALL_DIR" pull

## Force required permissions
chmod ug=rwx,o=rx ${INSTALL_DIR}*.sh
chmod ugo=rw ${INSTALL_DIR}*.conf

## Symlink (globally-available zzmysqldump command)
if [ ! -e "/usr/bin/${SCRIPT_NAME}" ]; then
	ln -s ${INSTALL_DIR}${SCRIPT_NAME}.sh /usr/bin/${SCRIPT_NAME}
fi
