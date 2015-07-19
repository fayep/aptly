# Aptly
## Purpose
A self-contained apt repository manager
## Installation
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

## Usage

GLOBAL OPTIONS
--------------

−**architectures**=

list of architectures to consider during (comma−separated), default to all available

−**config**=

location of configuration file (default locations are /etc/aptly.conf, ~/.aptly.conf)

−**dep−follow−all−variants**=false

when processing dependencies, follow a & b if dependency is ’a|b’

−**dep−follow−recommends**=false

when processing dependencies, follow Recommends

−**dep−follow−source**=false

when processing dependencies, follow from binary to Source packages

−**dep−follow−suggests**=false

when processing dependencies, follow Suggests

CREATE NEW MIRROR
-----------------

**aptly mirror create** *name archive url distribution* [*component1* ...]

Creates mirror *name* of remote repository, aptly supports both regular and flat Debian repositories exported via HTTP and FTP. aptly would try download Release file from remote repository and verify its’ signature. Command line format resembles apt utlitily sources.list(5).

PPA urls could specified in short format:

    $ aptly mirror create *name* ppa:*user*/*project*

Example:

    $ aptly mirror create wheezy−main http://mirror.yandex.ru/debian/ wheezy main

Options:
 −**filter**=

filter packages in mirror

−**filter−with−deps**=false

when filtering, include dependencies of matching packages as well

−**force−components**=false

(only with component list) skip check that requested components are listed in Release file

−**ignore−signatures**=false

disable verification of Release file signatures

−**keyring**=

gpg keyring to use when verifying Release file (could be specified multiple times)

−**with−sources**=false

download source packages in addition to binary packages

−**with−udebs**=false

download .udeb packages (Debian installer support)

LIST MIRRORS
------------

**aptly mirror list**

List shows full list of remote repository mirrors.

Example:

    $ aptly mirror list

Options:
 −**raw**=false

display list in machine−readable format

SHOW DETAILS ABOUT MIRROR
-------------------------

**aptly mirror show** *name*

Shows detailed information about the mirror.

Example:

    $ aptly mirror show wheezy−main

Options:
 −**with−packages**=false

show detailed list of packages and versions stored in the mirror

DELETE MIRROR
-------------

**aptly mirror drop** *name*

Drop deletes information about remote repository mirror *name*. Package data is not deleted (since it could still be used by other mirrors or snapshots). If mirror is used as source to create a snapshot, aptly would refuse to delete such mirror, use flag −force to override.

Example:

    $ aptly mirror drop wheezy−main

Options:
 −**force**=false

force mirror deletion even if used by snapshots

UPDATE MIRROR
-------------

**aptly mirror update** *name*

Updates remote mirror (downloads package files and meta information). When mirror is created, this command should be run for the first time to fetch mirror contents. This command can be run multiple times to get updated repository contents. If interrupted, command can be safely restarted.

Example:

    $ aptly mirror update wheezy−main

Options:
 −**download−limit**=0

limit download speed (kbytes/sec)

−**force**=false

force update mirror even if it is locked by another process

−**ignore−checksums**=false

ignore checksum mismatches while downloading package files and metadata

−**ignore−signatures**=false

disable verification of Release file signatures

−**keyring**=

gpg keyring to use when verifying Release file (could be specified multiple times)

RENAMES MIRROR
--------------

**aptly mirror rename** *old−name new−name*

Command changes name of the mirror.Mirror name should be unique.

Example:

    $ aptly mirror rename wheezy−min wheezy−main

EDIT MIRROR SETTINGS
--------------------

**aptly mirror edit** *name*

Command edit allows one to change settings of mirror: filters, list of architectures.

Example:

    $ aptly mirror edit −filter=nginx −filter−with−deps some−mirror

Options:
 −**filter**=

filter packages in mirror

−**filter−with−deps**=false

when filtering, include dependencies of matching packages as well

−**with−sources**=false

download source packages in addition to binary packages

−**with−udebs**=false

download .udeb packages (Debian installer support)

SEARCH MIRROR FOR PACKAGES MATCHING QUERY
-----------------------------------------

**aptly mirror search** *name package−query*

Command search displays list of packages in mirror that match package query

Example:

    $ aptly mirror search wheezy−main ’$Architecture (i386), Name (% *−dev)’

Options:
 −**format**=

custom format for result printing

−**with−deps**=false

include dependencies into search results

ADD PACKAGES TO LOCAL REPOSITORY
--------------------------------

**aptly repo add** *name*

Command adds packages to local repository from .deb, .udeb (binary packages) and .dsc (source packages) files. When importing from directory aptly would do recursive scan looking for all files matching *.[u]deb or*.dsc patterns. Every file discovered would be analyzed to extract metadata, package would then be created and added to the database. Files would be imported to internal package pool. For source packages, all required files are added automatically as well. Extra files for source package should be in the same directory as \*.dsc file.

Example:

    $ aptly repo add testing myapp−0.1.2.deb incoming/

Options:
 −**force−replace**=false

when adding package that conflicts with existing package, remove existing package

−**remove−files**=false

remove files that have been imported successfully into repository

COPY PACKAGES BETWEEN LOCAL REPOSITORIES
----------------------------------------

**aptly repo copy** *src−name dst−name package−query* **...**

Command copy copies packages matching *package−query* from local repo *src−name* to local repo *dst−name*.

Example:

    $ aptly repo copy testing stable ’myapp (=0.1.12)’

Options:
 −**dry−run**=false

don’t copy, just show what would be copied

−**with−deps**=false

follow dependencies when processing package−spec

CREATE LOCAL REPOSITORY
-----------------------

**aptly repo create** *name*

Create local package repository. Repository would be empty when created, packages could be added from files, copied or moved from another local repository or imported from the mirror.

Example:

    $ aptly repo create testing

Options:
 −**comment**=

any text that would be used to described local repository

−**component**=main

default component when publishing

−**distribution**=

default distribution when publishing

−**uploaders−file**=

uploaders.json to be used when including .changes into this repository

DELETE LOCAL REPOSITORY
-----------------------

**aptly repo drop** *name*

Drop information about deletions from local repo. Package data is not deleted (since it could be still used by other mirrors or snapshots).

Example:

    $ aptly repo drop local−repo

Options:
 −**force**=false

force local repo deletion even if used by snapshots

EDIT PROPERTIES OF LOCAL REPOSITORY
-----------------------------------

**aptly repo edit** *name*

Command edit allows one to change metadata of local repository: comment, default distribution and component.

Example:

    $ aptly repo edit −distribution=wheezy testing

Options:
 −**comment**=

any text that would be used to described local repository

−**component**=

default component when publishing

−**distribution**=

default distribution when publishing

−**uploaders−file**=

uploaders.json to be used when including .changes into this repository

IMPORT PACKAGES FROM MIRROR TO LOCAL REPOSITORY
-----------------------------------------------

**aptly repo import** *src−mirror dst−repo package−query* **...**

Command import looks up packages matching *package−query* in mirror *src−mirror* and copies them to local repo *dst−repo*.

Example:

    $ aptly repo import wheezy−main testing nginx

Options:
 −**dry−run**=false

don’t import, just show what would be imported

−**with−deps**=false

follow dependencies when processing package−spec

LIST LOCAL REPOSITORIES
-----------------------

**aptly repo list**

List command shows full list of local package repositories.

Example:

    $ aptly repo list

Options:
 −**raw**=false

display list in machine−readable format

MOVE PACKAGES BETWEEN LOCAL REPOSITORIES
----------------------------------------

**aptly repo move** *src−name dst−name package−query* **...**

Command move moves packages matching *package−query* from local repo *src−name* to local repo *dst−name*.

Example:

    $ aptly repo move testing stable ’myapp (=0.1.12)’

Options:
 −**dry−run**=false

don’t move, just show what would be moved

−**with−deps**=false

follow dependencies when processing package−spec

REMOVE PACKAGES FROM LOCAL REPOSITORY
-------------------------------------

**aptly repo remove** *name package−query* **...**

Commands removes packages matching *package−query* from local repository *name*. If removed packages are not referenced by other repos or snapshots, they can be removed completely (including files) by running ’aptly db cleanup’.

Example:

    $ aptly repo remove testing ’myapp (=0.1.12)’

Options:
 −**dry−run**=false

don’t remove, just show what would be removed

SHOW DETAILS ABOUT LOCAL REPOSITORY
-----------------------------------

**aptly repo show** *name*

Show command shows full information about local package repository.

ex: $ aptly repo show testing

Options:
 −**with−packages**=false

show list of packages

RENAMES LOCAL REPOSITORY
------------------------

**aptly repo rename** *old−name new−name*

Command changes name of the local repo. Local repo name should be unique.

Example:

    $ aptly repo rename wheezy−min wheezy−main

SEARCH REPO FOR PACKAGES MATCHING QUERY
---------------------------------------

**aptly repo search** *name package−query*

Command search displays list of packages in local repository that match package query

Example:

    $ aptly repo search my−software ’$Architecture (i386), Name (% *−dev)’

Options:
 −**format**=

custom format for result printing

−**with−deps**=false

include dependencies into search results

ADD PACKAGES TO LOCAL REPOSITORIES BASED ON .CHANGES FILES
----------------------------------------------------------

**aptly repo include** \<file.changes\>|*directory* **...**

Command include looks for .changes files in list of arguments or specified directories. Each .changes file is verified, parsed, referenced files are put into separate temporary directory and added into local repository. Successfully imported files are removed by default.

Additionally uploads could be restricted with \<uploaders.json\> file. Rules in this file control uploads based on GPG key ID of .changes file signature and queries on .changes file fields.

Example:

    $ aptly repo include −repo=foo−release incoming/

Options:
 −**accept−unsigned**=false

accept unsigned .changes files

−**force−replace**=false

when adding package that conflicts with existing package, remove existing package

−**ignore−signatures**=false

disable verification of .changes file signature

−**keyring**=

gpg keyring to use when verifying Release file (could be specified multiple times)

−**no−remove−files**=false

don’t remove files that have been imported successfully into repository

−**repo**={{.Distribution}}

which repo should files go to, defaults to Distribution field of .changes file

−**uploaders−file**=

path to uploaders.json file

CREATES SNAPSHOT OF MIRROR (LOCAL REPOSITORY) CONTENTS
------------------------------------------------------

**aptly snapshot create** *name* **from mirror** *mirror−name* **| from repo** *repo−name* **| empty**

Command create *name* from mirror makes persistent immutable snapshot of remote repository mirror. Snapshot could be published or further modified using merge, pull and other aptly features.

Command create *name* from repo makes persistent immutable snapshot of local repository. Snapshot could be processed as mirror snapshots, and mixed with snapshots of remote mirrors.

Command create *name* empty creates empty snapshot that could be used as a basis for snapshot pull operations, for example. As snapshots are immutable, creating one empty snapshot should be enough.

Example:

    $ aptly snapshot create wheezy−main−today from mirror wheezy−main

LIST SNAPSHOTS
--------------

**aptly snapshot list**

Command list shows full list of snapshots created.

Example:

    $ aptly snapshot list

Options:
 −**raw**=false

display list in machine−readable format

−**sort**=name

display list in ’name’ or creation ’time’ order

SHOWS DETAILS ABOUT SNAPSHOT
----------------------------

**aptly snapshot show** *name*

Command show displays full information about a snapshot.

Example:

    $ aptly snapshot show wheezy−main

Options:
 −**with−packages**=false

show list of packages

VERIFY DEPENDENCIES IN SNAPSHOT
-------------------------------

**aptly snapshot verify** *name* [*source* ...]

Verify does dependency resolution in snapshot *name*, possibly using additional snapshots *source* as dependency sources. All unsatisfied dependencies are printed.

Example:

    $ aptly snapshot verify wheezy−main wheezy−contrib wheezy−non−free

PULL PACKAGES FROM ANOTHER SNAPSHOT
-----------------------------------

**aptly snapshot pull** *name source destination package−query* **...**

Command pull pulls new packages along with its’ dependencies to snapshot *name* from snapshot *source*. Pull can upgrade package version in *name* with versions from *source* following dependencies. New snapshot *destination* is created as a result of this process. Packages could be specified simply as ’package−name’ or as package queries.

Example:

    $ aptly snapshot pull wheezy−main wheezy−backports wheezy−new−xorg xorg−server−server

Options:
 −**all−matches**=false

pull all the packages that satisfy the dependency version requirements

−**dry−run**=false

don’t create destination snapshot, just show what would be pulled

−**no−deps**=false

don’t process dependencies, just pull listed packages

−**no−remove**=false

don’t remove other package versions when pulling package

DIFFERENCE BETWEEN TWO SNAPSHOTS
--------------------------------

**aptly snapshot diff** *name−a name−b*

Displays difference in packages between two snapshots. Snapshot is a list of packages, so difference between snapshots is a difference between package lists. Package could be either completely missing in one snapshot, or package is present in both snapshots with different versions.

Example:

    $ aptly snapshot diff −only−matching wheezy−main wheezy−backports

Options:
 −**only−matching**=false

display diff only for matching packages (don’t display missing packages)

MERGES SNAPSHOTS
----------------

**aptly snapshot merge** *destination source* [*source*...]

Merge command merges several *source* snapshots into one *destination* snapshot. Merge happens from left to right. By default, packages with the same name−architecture pair are replaced during merge (package from latest snapshot on the list wins). If run with only one source snapshot, merge copies *source* into *destination*.

Example:

    $ aptly snapshot merge wheezy−w−backports wheezy−main wheezy−backports

Options:
 −**latest**=false

use only the latest version of each package

−**no−remove**=false

don’t remove duplicate arch/name packages

DELETE SNAPSHOT
---------------

**aptly snapshot drop** *name*

Drop removes information about a snapshot. If snapshot is published, it can’t be dropped.

Example:

    $ aptly snapshot drop wheezy−main

Options:
 −**force**=false

remove snapshot even if it was used as source for other snapshots

RENAMES SNAPSHOT
----------------

**aptly snapshot rename** *old−name new−name*

Command changes name of the snapshot. Snapshot name should be unique.

Example:

    $ aptly snapshot rename wheezy−min wheezy−main

SEARCH SNAPSHOT FOR PACKAGES MATCHING QUERY
-------------------------------------------

**aptly snapshot search** *name package−query*

Command search displays list of packages in snapshot that match package query

Example:

    $ aptly snapshot search wheezy−main ’$Architecture (i386), Name (% *−dev)’

Options:
 −**format**=

custom format for result printing

−**with−deps**=false

include dependencies into search results

FILTER PACKAGES IN SNAPSHOT PRODUCING ANOTHER SNAPSHOT
------------------------------------------------------

**aptly snapshot filter** *source destination package−query* **...**

Command filter does filtering in snapshot *source*, producing another snapshot *destination*. Packages could be specified simply as ’package−name’ or as package queries.

Example:

    $ aptly snapshot filter wheezy−main wheezy−required ’Priorioty (required)’

Options:
 −**with−deps**=false

include dependent packages as well

REMOVE PUBLISHED REPOSITORY
---------------------------

**aptly publish drop** *distribution* [[*endpoint*:]*prefix*]

Command removes whatever has been published under specified *prefix*, publishing *endpoint* and *distribution* name.

Example:

    $ aptly publish drop wheezy

Options:
 −**force−drop**=false

remove published repository even if some files could not be cleaned up

LIST OF PUBLISHED REPOSITORIES
------------------------------

**aptly publish list**

Display list of currently published snapshots.

Example:

    $ aptly publish list

Options:
 −**raw**=false

display list in machine−readable format

PUBLISH LOCAL REPOSITORY
------------------------

**aptly publish repo** *name* [[*endpoint*:]*prefix*]

Command publishes current state of local repository ready to be consumed by apt tools. Published repostiories appear under rootDir/public directory. Valid GPG key is required for publishing.

Multiple component repository could be published by specifying several components split by commas via −component flag and multiple local repositories as the arguments:

<table>
<colgroup>
<col width="50%" />
<col width="50%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>aptly publish repo −component=main,contrib repo−main repo−contrib</p></td>
</tr>
</tbody>
</table>

It is not recommended to publish local repositories directly unless the repository is for testing purposes and changes happen frequently. For production usage please take snapshot of repository and publish it using publish snapshot command.

Example:

    $ aptly publish repo testing

Options:
 −**batch**=false

run GPG with detached tty

−**component**=

component name to publish (for multi−component publishing, separate components with commas)

−**distribution**=

distribution name to publish

−**force−overwrite**=false

overwrite files in package pool in case of mismatch

−**gpg−key**=

GPG key ID to use when signing the release

−**keyring**=

GPG keyring to use (instead of default)

−**label**=

label to publish

−**origin**=

origin name to publish

−**passphrase**=

GPG passhprase for the key (warning: could be insecure)

−**passphrase−file**=

GPG passhprase−file for the key (warning: could be insecure)

−**secret−keyring**=

GPG secret keyring to use (instead of default)

−**skip−contents**=false

don’t generate Contents indexes

−**skip−signing**=false

don’t sign Release files with GPG

PUBLISH SNAPSHOT
----------------

**aptly publish snapshot** *name* [[*endpoint*:]*prefix*]

Command publishes snapshot as Debian repository ready to be consumed by apt tools. Published repostiories appear under rootDir/public directory. Valid GPG key is required for publishing.

Multiple component repository could be published by specifying several components split by commas via −component flag and multiple snapshots as the arguments:

    $ aptly publish snapshot −component=main,contrib snap−main snap−contrib

Example:

    $ aptly publish snapshot wheezy−main

Options:
 −**batch**=false

run GPG with detached tty

−**component**=

component name to publish (for multi−component publishing, separate components with commas)

−**distribution**=

distribution name to publish

−**force−overwrite**=false

overwrite files in package pool in case of mismatch

−**gpg−key**=

GPG key ID to use when signing the release

−**keyring**=

GPG keyring to use (instead of default)

−**label**=

label to publish

−**origin**=

origin name to publish

−**passphrase**=

GPG passhprase for the key (warning: could be insecure)

−**passphrase−file**=

GPG passhprase−file for the key (warning: could be insecure)

−**secret−keyring**=

GPG secret keyring to use (instead of default)

−**skip−contents**=false

don’t generate Contents indexes

−**skip−signing**=false

don’t sign Release files with GPG

UPDATE PUBLISHED REPOSITORY BY SWITCHING TO NEW SNAPSHOT
--------------------------------------------------------

**aptly publish switch** *distribution* [[*endpoint*:]*prefix*] *new−snapshot*

Command switches in−place published snapshots with new snapshot contents. All publishing parameters are preserved (architecture list, distribution, component).

For multiple component repositories, flag −component should be given with list of components to update. Corresponding snapshots should be given in the same order, e.g.:

<table>
<colgroup>
<col width="50%" />
<col width="50%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>aptly publish switch −component=main,contrib wheezy wh−main wh−contrib</p></td>
</tr>
</tbody>
</table>

Example:

    $ aptly publish switch wheezy ppa wheezy−7.5

This command would switch published repository (with one component) named ppa/wheezy (prefix ppa, dsitribution wheezy to new snapshot wheezy−7.5).

Options:
 −**batch**=false

run GPG with detached tty

−**component**=

component names to update (for multi−component publishing, separate components with commas)

−**force−overwrite**=false

overwrite files in package pool in case of mismatch

−**gpg−key**=

GPG key ID to use when signing the release

−**keyring**=

GPG keyring to use (instead of default)

−**passphrase**=

GPG passhprase for the key (warning: could be insecure)

−**passphrase−file**=

GPG passhprase−file for the key (warning: could be insecure)

−**secret−keyring**=

GPG secret keyring to use (instead of default)

−**skip−contents**=false

don’t generate Contents indexes

−**skip−signing**=false

don’t sign Release files with GPG

UPDATE PUBLISHED LOCAL REPOSITORY
---------------------------------

**aptly publish update** *distribution* [[*endpoint*:]*prefix*]

Command re−publishes (updates) published local repository. *distribution* and *prefix* should be occupied with local repository published using command aptly publish repo. Update happens in−place with minimum possible downtime for published repository.

For multiple component published repositories, all local repositories are updated.

Example:

    $ aptly publish update wheezy ppa

Options:
 −**batch**=false

run GPG with detached tty

−**force−overwrite**=false

overwrite files in package pool in case of mismatch

−**gpg−key**=

GPG key ID to use when signing the release

−**keyring**=

GPG keyring to use (instead of default)

−**passphrase**=

GPG passhprase for the key (warning: could be insecure)

−**passphrase−file**=

GPG passhprase−file for the key (warning: could be insecure)

−**secret−keyring**=

GPG secret keyring to use (instead of default)

−**skip−contents**=false

don’t generate Contents indexes

−**skip−signing**=false

don’t sign Release files with GPG

SEARCH FOR PACKAGES MATCHING QUERY
----------------------------------

**aptly package search** *package−query*

Command search displays list of packages in whole DB that match package query

Example:

    $ aptly package search ’$Architecture (i386), Name (% *−dev)’

Options:
 −**format**=

custom format for result printing

SHOW DETAILS ABOUT PACKAGES MATCHING QUERY
------------------------------------------

**aptly package show** *package−query*

Command shows displays detailed meta−information about packages matching query. Information from Debian control file is displayed. Optionally information about package files and inclusion into mirrors/snapshots/local repos is shown.

Example:

    $ aptly package show nginx−light_1.2.1−2.2+wheezy2_i386’

Options:
 −**with−files**=false

display information about files from package pool

−**with−references**=false

display information about mirrors, snapshots and local repos referencing this package

CLEANUP DB AND PACKAGE POOL
---------------------------

**aptly db cleanup**

Database cleanup removes information about unreferenced packages and removes files in the package pool that aren’t used by packages anymore

Example:

    $ aptly db cleanup

Options:
 −**dry−run**=false

don’t delete anything

−**verbose**=false

be verbose when loading objects/removing them

RECOVER DB AFTER CRASH
----------------------

**aptly db recover**

Database recover does its’ best to recover the database after a crash. It is recommended to backup the DB before running recover.

Example:

    $ aptly db recover

HTTP SERVE PUBLISHED REPOSITORIES
---------------------------------

**aptly serve**

Command serve starts embedded HTTP server (not suitable for real production usage) to serve contents of public/ subdirectory of aptly’s root that contains published repositories.

Example:

    $ aptly serve −listen=:8080

Options:
 −**listen**=:8080

host:port for HTTP listening

START API HTTP SERVICE
----------------------

**aptly api serve**

Stat HTTP server with aptly REST API.

Example:

    $ aptly api serve −listen=:8080

Options:
 −**listen**=:8080

host:port for HTTP listening

RENDER GRAPH OF RELATIONSHIPS
-----------------------------

**aptly graph**

Command graph displays relationship between mirrors, local repositories, snapshots and published repositories using graphviz package to render graph as an image.

Example:

    $ aptly graph

Options:
 −**format**=png

render graph to specified format (png, svg, pdf, etc.)

−**output**=

specify output filename, default is to open result in viewer

SHOW CURRENT APTLY’S CONFIG
---------------------------

**aptly config show**

Command show displays the current aptly configuration.

Example:

    $ aptly config show

RUN APTLY TASKS
---------------

**aptly task run** −filename=*filename* **|** *command1*, *command2*, **...**

Command helps organise multiple aptly commands in one single aptly task, running as single thread.

Example:

    $ aptly task run

    > repo create local
    > repo add local pkg1
    > publish repo local
    > serve
    >

Options:
 −**filename**=

specifies the filename that contains the commands to run

SHOW CURRENT APTLY’S CONFIG
---------------------------

**aptly config show**

Command show displays the current aptly configuration.

Example:

    $ aptly config show

ENVIRONMENT
-----------

If environment variable **HTTP\_PROXY** is set **aptly** would use its value to proxy all HTTP requests.

RETURN VALUES
-------------

**aptly** exists with:

<table>
<colgroup>
<col width="20%" />
<col width="20%" />
<col width="20%" />
<col width="20%" />
<col width="20%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>0</p></td>
<td align="left"></td>
<td align="left"><p>success</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>1</p></td>
<td align="left"></td>
<td align="left"><p>general failure</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>2</p></td>
<td align="left"></td>
<td align="left"><p>command parse failure</p></td>
<td align="left"></td>
</tr>
</tbody>
</table>

AUTHORS
-------

List of contributors, in chronological order:

<table>
<colgroup>
<col width="20%" />
<col width="20%" />
<col width="20%" />
<col width="20%" />
<col width="20%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Andrey Smirnov (https://github.com/smira)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Sebastien Binet (https://github.com/sbinet)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Ryan Uber (https://github.com/ryanuber)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Simon Aquino (https://github.com/queeno)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Vincent Batoufflet (https://github.com/vbatoufflet)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Ivan Kurnosov (https://github.com/zerkms)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Dmitrii Kashin (https://github.com/freehck)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Chris Read (https://github.com/cread)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Rohan Garg (https://github.com/shadeslayer)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Russ Allbery (https://github.com/rra)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Sylvain Baubeau (https://github.com/lebauce)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Andrea Bernardo Ciddio (https://github.com/bcandrea)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Michael Koval (https://github.com/mkoval)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Alexander Guy (https://github.com/alexanderguy)</p></td>
<td align="left"></td>
</tr>
<tr class="odd">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Sebastien Badia (https://github.com/sbadia)</p></td>
<td align="left"></td>
</tr>
<tr class="even">
<td align="left"></td>
<td align="left"><p>○</p></td>
<td align="left"></td>
<td align="left"><p>Szymon Sobik (https://github.com/sobczyk)</p></td>
<td align="left"></td>
</tr>
</tbody>
</table>

## Author
Faye Salwin faye.salwin@opower.com
