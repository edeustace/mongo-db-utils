require 'mongo-db-utils'

describe MongoDbUtils::Runner do
  it "should say hello" do
    MongoDbUtils::Runner.say_hello("ed").should eql("hello ed")
  end
end

