## Title and graphics
FRAME="O===========================================================O"
echo "$FRAME"
echo -e "\t $SCRIPT_NAME - $(date)"
echo "$FRAME"

## Enviroment variables
TIME_START="$(date +%s)"
DOWEEK="$(date +'%u')"
HOSTNAME="$(hostname)"

## Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT_FULLPATH=$(readlink -f "$0")

## Absolute path this script is in, thus /home/user/bin
SCRIPT_DIR=$(dirname "$SCRIPT_FULLPATH")/

## Default config files
CONFIGFILE_FULLPATH_DEFAULT=${SCRIPT_DIR}${SCRIPT_NAME}.default.conf
CONFIGFILE_MYSQL_FULLPATH_ETC=/etc/turbolab.it/mysql.conf
CONFIGFILE_NAME=$SCRIPT_NAME.conf
CONFIGFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_NAME
CONFIGFILE_FULLPATH_DIR=${SCRIPT_DIR}${CONFIGFILE_NAME}

## Config reading function
function zzmysqldumpConfigSet()
{
  for CONFIGFILE_FULLPATH in "$@"
  do
    if [ -f "$CONFIGFILE_FULLPATH" ]; then
      source "$CONFIGFILE_FULLPATH"
    fi
  done
  
  ## Add a slash to the output directory if missing
  MYSQL_BACKUP_DIR="${MYSQL_BACKUP_DIR%/}/"
}

zzmysqldumpConfigSet "$CONFIGFILE_FULLPATH_DEFAULT" "$CONFIGFILE_MYSQL_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_ETC" "$CONFIGFILE_FULLPATH_DIR"


## Config reading function (from zzmysqldump profile)
function zzmysqldumpProfileConfigSet()
{
  local CONFIGFILE_PROFILE_NAME=${SCRIPT_NAME}.profile.${1}.conf
  local CONFIGFILE_PROFILE_FULLPATH_ETC=/etc/turbolab.it/$CONFIGFILE_PROFILE_NAME
  local CONFIGFILE_PROFILE_FULLPATH_DIR=${SCRIPT_DIR}$CONFIGFILE_PROFILE_NAME
  
  if [[ "$1" == /* ]]; then
  
    local CONFIGFILE_EXPLICIT=$1
    
  fi
  
  if [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_ETC" ] && [ ! -f "$CONFIGFILE_PROFILE_FULLPATH_DIR" ] && [ ! -f "$CONFIGFILE_EXPLICIT" ]; then

    echo ""
    echo "vvvvvvvvvvvvvvvvvvvv"
    echo "Catastrophic error!!"
    echo "^^^^^^^^^^^^^^^^^^^^"
    echo "Profile config file(s) not found:"
    echo "[X] $CONFIGFILE_PROFILE_FULLPATH_ETC"
    echo "[X] $CONFIGFILE_PROFILE_FULLPATH_DIR"
    
    if [ -z "$CONFIGFILE_EXPLICIT" ]; then
    
      echo "[X] no explicit file provided via CLI"
    
    else
    
      echo "[X] $CONFIGFILE_EXPLICIT "
    
    fi


    echo ""
    echo "How to fix it?"
    echo "--------------"
    echo "Create a config file for this profile:"
    echo "sudo cp $CONFIGFILE_FULLPATH_DEFAULT $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo nano $CONFIGFILE_PROFILE_FULLPATH_ETC && sudo chmod u=rw,go=r $CONFIGFILE_PROFILE_FULLPATH_ETC && ${SCRIPT_NAME} $1"

    zzmysqldumpPrintEndFooter
    exit
    
  fi
  
  zzmysqldumpConfigSet "$CONFIGFILE_PROFILE_FULLPATH_ETC" "$CONFIGFILE_PROFILE_FULLPATH_DIR" "$CONFIGFILE_EXPLICIT"
}



## Retrive databases list and test connection
function listDatabases()
{
  if [ ! -z "$MYSQL_PASSWORD" ]; then
    local MYSQL_PASSWORD_HIDDEN="${MYSQL_PASSWORD:0:1}**...**${MYSQL_PASSWORD: -1}"
  fi  
    
  echo ""
  echo "Current config"
  echo "--------------"
  echo "User: ##${MYSQL_USER}##"
  echo "Pass: ##${MYSQL_PASSWORD_HIDDEN}##"
  echo "Host: ##${MYSQL_HOST}##"

  echo ""
  echo "Retrieving DBs list"
  echo "-------------------"
  DATABASES=$(mysql -N -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h "${MYSQL_HOST}" -e 'show databases')

  if [ $? -eq 0 ]; then

    echo $DATABASES
    
  else
  
    zzmysqldumpPrintEndFooter
    exit

  fi
}

## Footer function
function zzmysqldumpPrintEndFooter()
{
  echo ""
  echo "Time took"
  echo "---------"
  echo "$((($(date +%s)-$TIME_START)/60)) min."

  echo ""
  echo "The End"
  echo "-------"
  echo $(date)
  echo "$FRAME"
}

