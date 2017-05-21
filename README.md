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
