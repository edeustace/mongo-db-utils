require 'mongo-db-utils/models'


describe MongoDbUtils::Model do

  it "should parse mongo uris" do

    uri = "mongodb://localhost:27017/ed-backup"
    db = MongoDbUtils::Model::Db.from_uri(uri)
    db.to_s.should eql(uri)
    db.host.should eql("localhost")
    db.port.should eql("27017")
    db.name.should eql("ed-backup")
    db.username.should eql("")

    db.authentication_required?.should eql(false)

  end

  it "should parse mongo uris" do

    uri = "mongodb://ed:password@localhost:27017/ed-backup"
    db = MongoDbUtils::Model::Db.from_uri(uri)
    db.to_s.should eql(uri)
    db.host.should eql("localhost")
    db.port.should eql("27017")
    db.name.should eql("ed-backup")
    db.username.should eql("ed")
    db.password.should eql("password")
    db.authentication_required?.should eql(true)

  end

  it "should return nil if its a bad uri" do

    uri = ""
    db = MongoDbUtils::Model::Db.from_uri(uri)
    db.should be(nil)
  end

  class MockWriter
    def save(config)
    end

    def flush
    end
  end


  it "config should add dbs only if they are different" do
    config = MongoDbUtils::Model::Config.new
    config.writer = MockWriter.new

    config.add_db_from_uri("mongodb://blah:3333@server:123/blah")
    config.dbs.length.should eql(1)
    config.add_db_from_uri("mongodb://blah:3333@server:123/blah")
    config.dbs.length.should eql(1)
    # still the same server + name
    config.add_db_from_uri("mongodb://server:123/blah")
    config.dbs.length.should eql(1)
     config.add_db_from_uri("mongodb://server2:123/blah")
    config.dbs.length.should eql(2)
  end

end
