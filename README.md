# zzmysqldump
mysqldump every DB of your MySQL Server to its own, 7z-compressed file. The provided `setup.sh` auto-installs/updates the code and makes the script available as a new, simple shell command (`zzmysqldump`). The project aims to deliver a fully configfile-driven script: no code editing should be necessary!

**Parli italiano?** » Leggi: [MySQL/mysqldump: creare un file distinto/singolo per ogni database con zzmysqldump (script)](https://turbolab.it/server-1224/mysql-mysqldump-creare-file-distinto-singolo-ogni-database-zzmysqldump-script-1311)

![logo](https://turbolab.it/immagini/max/mysql-mysqldump-creare-file-distinto-singolo-ogni-database-zzmysqldump-script-zzmysqldump-spotlight-8837.img)


# Install
Just execute:

`curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo sh`

Now copy the provided sample configuration file (`zzmysqldump.default.conf`) to your own `zzmysqldump.conf` and replace username, password and stuff:

🤓 You don't need to set the `MYSQL_` vars to `root` if `/etc/turbolab.it/mysql.conf` exists! Pro tip: if you set the server up with [webstack](https://github.com/TurboLabIt/webstackup), the file was generated automatically. Just make sure you have the permission to read it, or run zzmysqldump as sudo.

`sudo cp /usr/local/turbolab.it/zzmysqldump/zzmysqldump.default.conf /etc/turbolab.it/zzmysqldump.conf && sudo nano /etc/turbolab.it/zzmysqldump.conf`


# Run it
It's MySQL Server backup time! Run `zzmysqldump` to generate your 7z-compressed, database-dump files.


# Known issues (which are not features, for real)

-> `mysqldump: Couldn't execute 'FLUSH TABLES': Access denied; you need (at least one of) the RELOAD privilege(s) for this operation (1227)`

Some extra privileges are needed for the `--lock-all-tables` mysqldump argument activated by the default configuration. root has it, other users don't.

As root, grant it: `GRANT RELOAD, PROCESS ON *.* TO 'your_user'@'127.0.0.1'` (some of these can only be granted globally, not to a particular database).

If you can't grant the RELOAD privilege to your user and you are in a dev/low-traffic enviroment, you can just remove `--lock-all-tables` in your config. For example, just leave `MYSQLDUMP_OPTIONS="--opt --add-drop-database"`

-> `7-zipping` fails. `Error: Incorrect command line`

Your 7za package is ancient! It's failing due to the `-sdel` argument, introduced by 7-zip 9.30 alpha (2012-10-26). You can just remove this argument in your config. For example, just leave `SEVENZIP_COMPRESS_OPTIONS="-t7z -mx=9 -mfb=256 -md=256m -ms=on"`
