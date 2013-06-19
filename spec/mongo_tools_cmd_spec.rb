require 'mongo-db-utils/tools/commands'

describe MongoDbUtils::Tools::Dump do

  dump = MongoDbUtils::Tools::Dump

  it "should work with single uris" do
    dump.cmd("host:port", "db", "out", "user", "pass").should eql "mongodump -h host:port -db db -u user -p pass -o out"
  end

  it "should work with single uris - no user/pass" do
    dump.cmd("host:port", "db", "out").should eql "mongodump -h host:port -db db -o out"
  end

  it "should work with replica set uris" do
    expected = "mongodump -h setname/host1:port1,host2:port2 -db db -u user -p pass -o out"
    dump.cmd("setname/host1:port1,host2:port2","db", "out", "user", "pass").should eql expected
  end
end


describe MongoDbUtils::Tools::Restore do

  restore = MongoDbUtils::Tools::Restore

  it "should work with single uris" do
    restore.cmd("host:port", "db", "source", "user", "pass").should eql "mongorestore -h host:port -db db -u user -p pass --drop source"
  end

  it "should work with single uris" do
    restore.cmd("host:port", "db", "source").should eql "mongorestore -h host:port -db db --drop source"
  end

  it "should work with replica set uris" do
    expected = "mongorestore -h setname/host1:port1,host2:port2 -db db -u user -p pass --drop source"
    restore.cmd("setname/host1:port1,host2:port2","db", "source", "user", "pass").should eql expected
  end
end