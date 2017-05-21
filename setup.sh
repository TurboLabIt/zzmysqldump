#!/bin/bash
clear

## Script name
SCRIPT_NAME=zzmysqldump

## Pre-requisites
if [ -f "/etc/redhat-release" ]; then
	yum clean all
	yum install epel-release -y
	yum clean all
	yum install git mysql-community-client p7zip -y
else
	apt update
	apt install git mysql-client p7zip-full -y
fi


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
	pushd "$INSTALL_DIR_PARENT"
	git clone https://github.com/TurboLabIt/${SCRIPT_NAME}.git
	popd
else
	echo "Updating..."
	echo "----------"
fi

## Fetch & pull new code
pushd "$INSTALL_DIR"
git -C "$INSTALL_DIR" fetch origin
git -C "$INSTALL_DIR" pull
popd

## Force required permissions
chmod ug=rwx,o=rx ${INSTALL_DIR}*.sh
chmod ugo=rw ${INSTALL_DIR}*.conf

## Symlink (globally-available zzmysqldump command)
if [ ! -e "/usr/bin/${SCRIPT_NAME}" ]; then
	ln -s ${INSTALL_DIR}${SCRIPT_NAME}.sh /usr/bin/${SCRIPT_NAME}
fi
