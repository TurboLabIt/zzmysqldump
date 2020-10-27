# zzmysqldump
mysqldump every DB of your MySQL Server to its own, 7z-compressed file. The provided `setup.sh` auto-installs/updates the code and makes the script available as a new, simple shell command (`zzmysqldump`). The project aims to deliver a fully configfile-driven script: no code editing should be necessary!

**Parli italiano?** » Leggi: [MySQL/mysqldump: creare un file distinto/singolo per ogni database con zzmysqldump (script)](https://turbolab.it/server-1224/mysql-mysqldump-creare-file-distinto-singolo-ogni-database-zzmysqldump-script-1311)

# Install
Just execute:

`curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo sh`

Now copy the provided sample configuration file (`zzmysqldump.default.conf`) to your own `zzmysqldump.conf` and replace username, password and stuff:

`sudo cp /usr/local/turbolab.it/zzmysqldump/zzmysqldump.default.conf /etc/turbolab.it/zzmysqldump.conf && sudo nano /etc/turbolab.it/zzmysqldump.conf`

# Run it
It's MySQL Server backup time! Run `zzmysqldump` to generate your 7z-compressed, database-dump files.

# Known issues

-> `mysqldump: Couldn't execute 'FLUSH TABLES': Access denied; you need (at least one of) the RELOAD privilege(s) for this operation (1227)`

The RELOAD privilege is needed for the `--lock-all-tables` mysqldump argument activated by the default configuration. root has it, other users don't.

As root, grant it: `GRANT RELOAD ON *.* TO 'your_user'@'127.0.0.1'` (RELOAD can only be granted globally, not to a particular database). Problem solved.

If you can't grant the RELOAD privilege to your user and you are in a dev/low-traffic enviroment, you can just remove `--lock-all-tables` in your config. For example, just leave `MYSQLDUMP_OPTIONS="--opt --add-drop-database"`

-> `7-zipping` fails. `Error: Incorrect command line`

Your 7za package is ancient! It's failing due to the `-sdel` argument, introduced by 7-zip 9.30 alpha (2012-10-26). You can just remove this argument in your config. For example, just leave `SEVENZIP_COMPRESS_OPTIONS="-t7z -mx=9 -mfb=256 -md=256m -ms=on"`
