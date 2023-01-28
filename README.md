# zzmysqldump

mysqldump every DB of your MySQL Server to its own, 7z-compressed file. The provided `setup.sh` auto-installs/updates the code and makes the script available as a new, simple shell command (`zzmysqldump`). The project aims to deliver a fully configfile-driven script: no code editing should be necessary!

**Parli italiano?** » Leggi: [MySQL/mysqldump: creare un file distinto/singolo per ogni database con zzmysqldump (script)](https://turbolab.it/server-1224/mysql-mysqldump-creare-file-distinto-singolo-ogni-database-zzmysqldump-script-1311)

![logo](https://turbolab.it/immagini/max/mysql-mysqldump-creare-file-distinto-singolo-ogni-database-zzmysqldump-script-zzmysqldump-spotlight-8837.img)


# Install

Just execute:

````bash
sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh?$(date +%s) | sudo bash

````

Now copy the provided sample configuration file (`zzmysqldump.default.conf`) to your own `zzmysqldump.conf` and replace username, password and stuff:

🤓 You don't need to set the `MYSQL_` vars to `root` if `/etc/turbolab.it/mysql.conf` exists! Pro tip: if you set the server up with [webstack](https://github.com/TurboLabIt/webstackup), the file was generated automatically. Just make sure you have the permission to read it, or run zzmysqldump as sudo.

````bash
sudo cp /usr/local/turbolab.it/zzmysqldump/zzmysqldump.default.conf /etc/turbolab.it/zzmysqldump.conf && sudo nano /etc/turbolab.it/zzmysqldump.conf

````


# Run it

It's MySQL Server backup time! Run `zzmysqldump` to generate your 7z-compressed, database-dump files.


# Import

Import a dump


````shell
zzmysqldump mydump.sql.7z

````


Import a dump but change the imported database name:


````shell
zzmysqldump mydump.sql.7z new-database-name

````


# Known issues (which are not features, for real)

-> `mysqldump: Couldn't execute 'FLUSH TABLES': Access denied; you need (at least one of) the RELOAD privilege(s) for this operation (1227)`

Some extra privileges are needed for the `--lock-all-tables` mysqldump argument activated by the default configuration. root has it, other users don't.

As root, grant it: `GRANT RELOAD, PROCESS ON *.* TO 'your_user'@'127.0.0.1'` (some of these can only be granted globally, not to a particular database).

If you can't grant the RELOAD privilege to your user and you are in a dev/low-traffic enviroment, you can just remove `--lock-all-tables` in your config. For example, just leave `MYSQLDUMP_OPTIONS="--opt --add-drop-database"`

-> `7-zipping` fails. `Error: Incorrect command line`

Your 7za package is ancient! It's failing due to the `-sdel` argument, introduced by 7-zip 9.30 alpha (2012-10-26). You can just remove this argument in your config. For example, just leave `SEVENZIP_COMPRESS_OPTIONS="-t7z -mx=9 -mfb=256 -md=256m -ms=on"`


# Database compression: test and results

The 7-zip compression is done with a command like this:

`7za a -t7z -mx=9 -mfb=256 -md=256m db-dump.sql.7z db-dump.sql`

[man 7za](https://linux.die.net/man/1/7za).

I run a test against some real life db dumps to find the best compression options for this specific use case.

````
clear
TIME_START="$(date +%s)"
7za a -t7z -mx=9 -mfb=256 -md=128m "db_contenuti_tli.sql -t7z -mx=9 -mfb=256 -md=128m.7z" db_contenuti_tli.sql
7za a -t7z -mx=9 -mfb=256 -md=128m "db_ecommerce_mobili.sql -t7z -mx=9 -mfb=256 -md=128m.7z" db_ecommerce_mobili.sql
7za a -t7z -mx=9 -mfb=256 -md=128m "db_ecommerce_turismo.sql -t7z -mx=9 -mfb=256 -md=128m.7z" db_ecommerce_turismo.sql
7za a -t7z -mx=9 -mfb=256 -md=128m "db_forum.sql -t7z -mx=9 -mfb=256 -md=128m.7z" db_forum.sql
7za a -t7z -mx=9 -mfb=256 -md=128m "db_wordpress.sql -t7z -mx=9 -mfb=256 -md=128m.7z" db_wordpress.sql
echo "$((($(date +%s)-$TIME_START)/60)) min."
## 19 min.

TIME_START="$(date +%s)"
7za a -t7z -mx=9 -mfb=128 -md=128m "db_contenuti_tli.sql -t7z -mx=9 -mfb=128 -md=128m.7z" db_contenuti_tli.sql
7za a -t7z -mx=9 -mfb=128 -md=128m "db_ecommerce_mobili.sql -t7z -mx=9 -mfb=128 -md=128m.7z" db_ecommerce_mobili.sql
7za a -t7z -mx=9 -mfb=128 -md=128m "db_ecommerce_turismo.sql -t7z -mx=9 -mfb=128 -md=128m.7z" db_ecommerce_turismo.sql
7za a -t7z -mx=9 -mfb=128 -md=128m "db_forum.sql -t7z -mx=9 -mfb=128 -md=128m.7z" db_forum.sql
7za a -t7z -mx=9 -mfb=128 -md=128m "db_wordpress.sql -t7z -mx=9 -mfb=128 -md=128m.7z" db_wordpress.sql
echo "$((($(date +%s)-$TIME_START)/60)) min."
## 12 min.

TIME_START="$(date +%s)"
7za a -t7z -mx=9 -mfb=64 -md=128m "db_contenuti_tli.sql -t7z -mx=9 -mfb=64 -md=128m.7z" db_contenuti_tli.sql
7za a -t7z -mx=9 -mfb=64 -md=128m "db_ecommerce_mobili.sql -t7z -mx=9 -mfb=64 -md=128m.7z" db_ecommerce_mobili.sql
7za a -t7z -mx=9 -mfb=64 -md=128m "db_ecommerce_turismo.sql -t7z -mx=9 -mfb=64 -md=128m.7z" db_ecommerce_turismo.sql
7za a -t7z -mx=9 -mfb=64 -md=128m "db_forum.sql -t7z -mx=9 -mfb=64 -md=128m.7z" db_forum.sql
7za a -t7z -mx=9 -mfb=64 -md=128m "db_wordpress.sql -t7z -mx=9 -mfb=64 -md=128m.7z" db_wordpress.sql
echo "$((($(date +%s)-$TIME_START)/60)) min."
## 8 min.

TIME_START="$(date +%s)"
7za a -t7z -mx=9 -mfb=128 -md=64m "db_contenuti_tli.sql -t7z -mx=9 -mfb=128 -md=64m.7z" db_contenuti_tli.sql
7za a -t7z -mx=9 -mfb=128 -md=64m "db_ecommerce_mobili.sql -t7z -mx=9 -mfb=128 -md=64m.7z" db_ecommerce_mobili.sql
7za a -t7z -mx=9 -mfb=128 -md=64m "db_ecommerce_turismo.sql -t7z -mx=9 -mfb=128 -md=64m.7z" db_ecommerce_turismo.sql
7za a -t7z -mx=9 -mfb=128 -md=64m "db_forum.sql -t7z -mx=9 -mfb=128 -md=64m.7z" db_forum.sql
7za a -t7z -mx=9 -mfb=128 -md=64m "db_wordpress.sql -t7z -mx=9 -mfb=128 -md=64m.7z" db_wordpress.sql
echo "$((($(date +%s)-$TIME_START)/60)) min."
## 11 min.

TIME_START="$(date +%s)"
7za a -t7z -mx=9 -mfb=64 -md=64m "db_contenuti_tli.sql -t7z -mx=9 -mfb=64 -md=64m.7z" db_contenuti_tli.sql
7za a -t7z -mx=9 -mfb=64 -md=64m "db_ecommerce_mobili.sql -t7z -mx=9 -mfb=64 -md=64m.7z" db_ecommerce_mobili.sql
7za a -t7z -mx=9 -mfb=64 -md=64m "db_ecommerce_turismo.sql -t7z -mx=9 -mfb=64 -md=64m.7z" db_ecommerce_turismo.sql
7za a -t7z -mx=9 -mfb=64 -md=64m "db_forum.sql -t7z -mx=9 -mfb=64 -md=64m.7z" db_forum.sql
7za a -t7z -mx=9 -mfb=64 -md=64m "db_wordpress.sql -t7z -mx=9 -mfb=64 -md=64m.7z" db_wordpress.sql
echo "$((($(date +%s)-$TIME_START)/60)) min."
## 8 min.
````

These options triggered the OoM-Killer midway through the 3,5G dump compression on my PC with 16 GB of RAM:

- `-mfb=256 -md=256m` 
- `-mfb=128 -md=256m`

Results:

````
exa -lh --color=always --no-user --no-time --no-permissions

 35M db_contenuti_tli.sql
5,2M db_contenuti_tli.sql -t7z -mx=9 -mfb=64 -md=64m.7z
5,2M db_contenuti_tli.sql -t7z -mx=9 -mfb=64 -md=128m.7z
5,1M db_contenuti_tli.sql -t7z -mx=9 -mfb=128 -md=64m.7z
5,1M db_contenuti_tli.sql -t7z -mx=9 -mfb=128 -md=128m.7z
5,1M db_contenuti_tli.sql -t7z -mx=9 -mfb=256 -md=128m.7z
3,5G db_ecommerce_mobili.sql
140M db_ecommerce_mobili.sql -t7z -mx=9 -mfb=64 -md=64m.7z
140M db_ecommerce_mobili.sql -t7z -mx=9 -mfb=64 -md=128m.7z
134M db_ecommerce_mobili.sql -t7z -mx=9 -mfb=128 -md=64m.7z
134M db_ecommerce_mobili.sql -t7z -mx=9 -mfb=128 -md=128m.7z
132M db_ecommerce_mobili.sql -t7z -mx=9 -mfb=256 -md=128m.7z
3,7G db_ecommerce_turismo.sql
670M db_ecommerce_turismo.sql -t7z -mx=9 -mfb=64 -md=64m.7z
662M db_ecommerce_turismo.sql -t7z -mx=9 -mfb=64 -md=128m.7z
668M db_ecommerce_turismo.sql -t7z -mx=9 -mfb=128 -md=64m.7z
660M db_ecommerce_turismo.sql -t7z -mx=9 -mfb=128 -md=128m.7z
657M db_ecommerce_turismo.sql -t7z -mx=9 -mfb=256 -md=128m.7z
183M db_forum.sql
 28M db_forum.sql -t7z -mx=9 -mfb=64 -md=64m.7z
 28M db_forum.sql -t7z -mx=9 -mfb=64 -md=128m.7z
 27M db_forum.sql -t7z -mx=9 -mfb=128 -md=64m.7z
 27M db_forum.sql -t7z -mx=9 -mfb=128 -md=128m.7z
 27M db_forum.sql -t7z -mx=9 -mfb=256 -md=128m.7z
 34M db_wordpress.sql
1,4M db_wordpress.sql -t7z -mx=9 -mfb=64 -md=64m.7z
1,4M db_wordpress.sql -t7z -mx=9 -mfb=64 -md=128m.7z
1,3M db_wordpress.sql -t7z -mx=9 -mfb=128 -md=64m.7z
1,3M db_wordpress.sql -t7z -mx=9 -mfb=128 -md=128m.7z
1,3M db_wordpress.sql -t7z -mx=9 -mfb=256 -md=128m.7z
 ````

Takeaways:

- the ratio difference is not significant
- the speed difference is huge

I chose `-mfb=64 -md=64m` as a default just because is the fastest. `-mx=9 -mfb=64 -md=128m` took more or less the same time, but only in one case it gave better result. So I went with 64/64m, just because it uses less RAM.
