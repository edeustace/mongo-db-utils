# Mongo::Db::Utils


1. copy a database from one server to another
  > eg: db-one@source.com -> db-two@target.com
  >> 1. create a backup of db-two: backups/target.com/db-two/2012.7.20_19.54
  >> 2. mongodump -h source.com -db db-one dumps/source.com/db-one/...
  >> 3. mongorestore -db db-two -h target.com dumps/source.com/db-one
  >> 4. rm -fr dumps/source.com/db-one
  >>
  >>
2. backup a database
  > eg: db-one@source.com
  >> 1. mongodump -h source.com -db db-one backups/source.com/db-one/2012.7.20_12.34
  >>
  >>


## Installation

Add this line to your application's Gemfile:

    gem 'mongo-db-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongo-db-utils

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
