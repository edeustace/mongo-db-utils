# MongoDbUtils

A little gem that simplifies backing up and copying your mongo dbs.

It saves your database urls so any task is just a few clicks.

* backup a database
* copy a database from one server to another (whilst backing up the target db if it exits)



## Installation

You need to have mongorestore and mongodump on your path.

Add this line to your application's Gemfile:

    gem 'mongo-db-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo-db-utils

## Usage

TODO: Write usage instructions here

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
