# Integration Test Environment

This folder contains utilities for setting up a mongo environment and running the console against it.
This is only really useful if you are working on the source code. If you're just using the gem you can ignore this stuff.

## Available Environments

### Standalone DB

* init the environment `create_two_standalone_dbs` - this creates 2 mongod instances on 27018/27019
* To run the console go: `bundle exec bin/mongo-db-utils console integration-test-env/standalone/config.yml`

* kill the environment `kill_processes standalone/.processes`


### Replica Set DBs

* `create_two_replica_sets`
* `replica_sets/rs_config` - you'll probably have to run this a few times
* `seed_replica_sets`
* run the console: `bundle exec bin/mongo-db-utils console integration-test-env/replica_sets/config.yml`

* kill the environment `kill_processes replica_sets/.processes`


