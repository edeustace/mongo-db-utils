# MongoDbUtils

A little gem that simplifies backing up and copying your mongo dbs.

It saves your database urls so any task is just a few clicks.

* backup a database
* copy a database from one server to another (whilst backing up the target db if it exists)



## Installation

You need to have mongodump on your path.

    gem install 'mongo-db-utils'

And then execute:

    $ mongo-db-utils console

## Usage
Once you launch the console it'll provide you with a set of options - pretty self explanatory.
When it does backups it stores them in ````~/.mongo-db-utils/backups/````. The naming convention is ````${server}_${port}/${database_name}/${timestamp}/db````


## Building source

    #run console
    bundle exec bin/mongo-db-utils console

    #install the gem locally
    rake build
    gem install pkg/mongo-db-utils.gem

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
