# zzmysqldump
mysqldump every DB of your MySQL Server to its own, 7z-compressed file. The provided `setup.sh` auto-installs/updates the code and makes the script available a new, simple shell command (`zzmysqldump`). The project aims to deliver a fully configfile-driven script: no code editing should be necessary!

# Install
Just execute:

`curl -s https://raw.githubusercontent.com/TurboLabIt/zzmysqldump/master/setup.sh | sudo sh`

Now copy the provided sample configuration file (`zzmysqldump.default.conf`) to your own `zzmysqldump.conf` and replace username, password and stuff with your own.

# Run it
It's MySQL Server backup time! Run `zzmysqldump` to generate your 7z-compressed, database-dump files.