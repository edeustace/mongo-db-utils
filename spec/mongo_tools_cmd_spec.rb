require 'mongo-db-utils/tools/commands'

include MongoDbUtils::Tools

describe Dump do

  it "should work with single uris" do
    Dump.new("host:port", "db", "out", "user", "pass").cmd.should eql "mongodump -h host:port -db db -u user -p pass -o out"
  end
  it "should work with single uris - no user/pass" do
    Dump.new("host:port", "db", "out").cmd.should eql "mongodump -h host:port -db db -o out"
  end

  it "should work with replica set uris" do
    expected = "mongodump -h setname/host1:port1,host2:port2 -db db -u user -p pass -o out"
    Dump.new("setname/host1:port1,host2:port2","db", "out", "user", "pass").cmd.should eql expected
  end
end

describe Restore do

  it "should work with single uris" do
    Restore.new("host:port", "db", "source", "user", "pass").cmd.should eql "mongorestore -h host:port -db db -u user -p pass --drop source"
  end

  it "should work with single uris" do
    Restore.new("host:port", "db", "source").cmd.should eql "mongorestore -h host:port -db db --drop source"
  end

  it "should work with replica set uris" do
    expected = "mongorestore -h setname/host1:port1,host2:port2 -db db -u user -p pass --drop source"
    Restore.new("setname/host1:port1,host2:port2","db", "source", "user", "pass").cmd.should eql expected
  end
end

describe Import do

  it "should work with single uris - with user/pass" do
    Import.new("host:port", "db", "coll", "myfile.json", "user", "pass").cmd.should eql "mongoimport -h host:port -db db -u user -p pass -c coll --file myfile.json"
  end

  it "should work with single uris - no user/pass" do
    Import.new("host:port", "db", "coll", "myfile.json").cmd.should eql "mongoimport -h host:port -db db -c coll --file myfile.json"
  end

  it "should work with replica set uris" do
    expected = "mongoimport -h setname/host1:port1,host2:port2 -db db -u user -p pass -c coll --file myfile.json --jsonArray"
    Import.new("setname/host1:port1,host2:port2","db", "coll", "myfile.json", "user", "pass", { :json_array => true} ).cmd.should eql expected
  end
end

describe Export do

  it "should work with single uris - with user/pass" do
    Export.new("host:port", "db", "coll", "{query}", "myfile.json", "user", "pass").cmd.should eql "mongoexport -h host:port -db db -u user -p pass -c coll -o myfile.json --query '{query}'"
  end

  it "should work with single uris - no user/pass" do
    Export.new("host:port", "db", "coll", "{query}", "myfile.json").cmd.should eql "mongoexport -h host:port -db db -c coll -o myfile.json --query '{query}'"
  end

  it "should work with replica set uris" do
    expected = "mongoexport -h setname/host1:port1,host2:port2 -db db -u user -p pass -c coll -o myfile.json --query '{query}' --jsonArray"
    Export.new("setname/host1:port1,host2:port2","db", "coll", "{query}", "myfile.json", "user", "pass", { :json_array => true} ).cmd.should eql expected
  end
end

describe Option do

  it "should return empty? correctly" do
    Option.new("a", "b").empty?.should eql false
    Option.new("a", "b").to_s.should eql "a b"
    Option.new("a").empty?.should eql true
    Option.new("a").to_s.should eql nil
    Option.new("").empty?.should eql true
  end

end
