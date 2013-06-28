require 'mongo-db-utils/models/db'

include MongoDbUtils::Model

describe MongoDbUtils::Model::Db do


  it "should construct" do
    db = Db.new("mongodb://user:pass@localhost:27017/db")
    db.to_host_s.should == "localhost:27017"
    db.name.should == "db"
    db.username.should == "user"
    db.password.should == "pass"
    db.uri == "mongodb://user:pass@localhost:27017/db"
    db.authentication_required?.should == true
  end

  it "should construct - no user/pass" do
    db = Db.new("mongodb://localhost:27017/db")
    db.to_host_s.should == "localhost:27017"
    db.name.should == "db"
    db.username.should == ""
    db.password.should == ""
    db.uri == "mongodb://localhost:27017/db"
    db.authentication_required?.should == false
  end

  it "should build a replicaset db" do
    rs = ReplicaSetDb.new("mongodb://user:pass@host:port,host2:port2/db", "my-set")
    rs.set_name.should == "my-set"
    rs.to_host_s === "my-set/host:port,host2:port2"
    rs.uri.should == "mongodb://user:pass@host:port,host2:port2/db"
    rs.authentication_required?.should == true
  end


  it "should parse the uri correctly" do
    MongoDbUtils::Model.db_from_uri("mongodb://localhost:27017/db").class.to_s.should == "MongoDbUtils::Model::Db"
    MongoDbUtils::Model.db_from_uri("set|mongodb://s:2,s:3/db").class.to_s.should == "MongoDbUtils::Model::ReplicaSetDb"
  end


  it "should parse a full url" do

    uri = "rs-ds063347|mongodb://user:pass@ds063347-a0.mongolab.com:63347,ds063347-a1.mongolab.com:63347/staging"
    db = MongoDbUtils::Model.db_from_uri(uri)
    db.username.should eql "user"
    db.password.should == "pass"
    db.to_host_s.should == "rs-ds063347/ds063347-a0.mongolab.com:63347,ds063347-a1.mongolab.com:63347"
  end

end
