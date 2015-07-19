# Aptly
## Purpose
A self-contained apt repository manager
## Usage
Add the missing private key as `aptly.asc`
Install with:

    docker build -t faye/aptly .
    docker run -v /mnt/aptly:/mnt --rm faye/aptly | /bin/bash

where `/mnt/aptly` is your repository mount.
Reinstall (if necessary) with:

    docker run --rm faye/aptly | /bin/bash


This installs a wrapper to `/usr/local/bin/aptly`.

Then usage is as with aptly except that private key handling is moved to
an environment variable.
    export GPG_PASSPHRASE="the passphrase"
Funky options required to make this work are done transparently.
## Author
Faye Salwin faye.salwin@opower.com
