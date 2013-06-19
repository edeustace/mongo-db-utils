# Integration Test Environment

This folder contains utilities for setting up a mongo environment and running the console against it.

## Available Environments

### Standalone DB

* init the environment `create_two_standalone_dbs` - this creates 2 mongod instances on 27018/27019
* To run the console go:

    bundle exec bin/mongo-db-utils console integration-test-env/standalone/config.yml

* kill the environment `kill_two_standalone_dbs`


### Replica Set DBs

....
