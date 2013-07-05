# MongoDbUtils

[![Build Status](https://travis-ci.org/edeustace/mongo-db-utils.png)](https://travis-ci.org/edeustace/mongo-db-utils)


### !Current version 0.1.1 is in Beta - for a safer version use 0.0.9

A little gem that simplifies backing up and copying your mongo dbs.

You can run as a script (eg for cron jobs, or in interactive mode):

![Sample](https://github.com/edeustace/mongo-db-utils/raw/master/images/grab.png)

It saves your database urls so any task is just a few clicks.

* backup a database locally
* backup a database and deploy it to Amazon S3
* copy a database from one server to another (whilst backing up locally the target db if it exists)

## Installation

You need to have *mongodump* and *mongorestore* on your path.

    gem install 'mongo-db-utils'

And then execute:

    $ mongo-db-utils console


## Limitatons

ruby >= 1.9.3

## Usage
Once you launch the console it'll provide you with a set of options - pretty self explanatory.
When it does backups it stores them in ````~/.mongo-db-utils/backups/````. The naming convention is ````${server}_${port}/${database_name}/${timestamp}/db````

## Testing

    bundle exec rspec spec

    #cucumber can't handle interactive CLIs so need to wait on this.
    #bundle exec cucumber features

## Building source

    #run console
    bundle exec bin/mongo-db-utils console path_to/config.yml (optional - it defaults to ~/.mongo-db-utils/config.yml)

    #install the gem locally
    rake build
    gem install pkg/mongo-db-utils.gem



## Release Notes
* 0.1.2 - BETA
  - Added 'host' and 'port' getters to Db AND 'hosts' getter to ReplicaSetDb

* 0.1.1 - BETA
  - Tidy up Tools - add Import and Restore to tool set

* 0.1.0 - BETA
  - Fixed CLI backup and backup_s3 not using the config-loader correctly.

* 0.0.9.3 - BETA!
  - Fixed config-loader require bug

* 0.0.9.2 - BETA! Warning - there was an error with config loader in this version use 0.0.9.3 instead.
  - Added support for Replica Sets
  - console can be run pointing to any config file: `console myconfig.yml`
  - More specs
  - Added local mongo environment to simplify testing @see: integration-test-env

* 0.0.9 - First release
  - Copy mongo dbs
  - Back up to S3
