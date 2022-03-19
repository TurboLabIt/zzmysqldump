#!/usr/bin/env bash
7za a $1 "${2}" "${3}" > "${4}" 2>&1
if [ $? -eq 0 ]; then

  rm -f "${4}"
  
fi

