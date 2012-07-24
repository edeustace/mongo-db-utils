# MongoDbUtils

## Warning - not safe for production use - undergoing development!

A little gem that simplifies backing up and copying your mongo dbs.

![Sample](https://github.com/edeustace/mongo-db-utils/raw/master/images/sample.png)

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

Only works on ruby 1.9.3 (to_yaml is throwing an error in earlier versions)

## Usage
Once you launch the console it'll provide you with a set of options - pretty self explanatory.
When it does backups it stores them in ````~/.mongo-db-utils/backups/````. The naming convention is ````${server}_${port}/${database_name}/${timestamp}/db````

## Testing
    
    bundle exec cucumber features
    
    bundle exec rspec spec
    
## Building source

    #run console
    bundle exec bin/mongo-db-utils console

    #install the gem locally
    rake build
    gem install pkg/mongo-db-utils.gem

