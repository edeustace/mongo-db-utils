require 'mongo-db-utils/models/config'

describe MongoDbUtils::Model::Config do

  class MockWriter
    attr_accessor :instance
    def save(instance)
      @instance = instance
    end

    def flush
    end
  end

  before(:each) do
    @config = MongoDbUtils::Model::Config.new
    @config.writer = MockWriter.new
  end

  it "should construct" do
    @config.should_not be_nil
  end

  it "should add a single db" do
    @config.add_single_db( "mongodb://localhost:27017/db")
    @config.dbs.length.should == 1
    @config.add_single_db( "mongodb://localhost:27017/db2")
    @config.dbs.length.should == 2
  end

  it "should not add the db if its already there" do
    @config.add_single_db( "mongodb://localhost:27017/db")
    @config.add_single_db( "mongodb://localhost:27017/db")
    @config.dbs.length.should == 1
  end

  it "should remove a single db" do
    @config.add_single_db( "mongodb://localhost:27017/db")
    @config.dbs.length.should == 1
    @config.remove_db(@config.dbs[0])
    @config.dbs.length.should == 0
  end

  it "should add a replica set" do
    @config.dbs.length.should == 0
    result = @config.add_replica_set("mongodb://user:pass@host:port,host2:port2/db", "setOne")
    @config.dbs.length.should == 1
    @config.remove_db(@config.dbs[0])
    @config.dbs.length.should == 0
  end

  it "should throw an exception if add a nil db" do
    expect { @config.add_single_db(nil)}.to raise_error
  end

end
