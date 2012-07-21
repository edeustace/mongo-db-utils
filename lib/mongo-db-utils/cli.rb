require 'thor'
require 'mongo-db-utils'

module MongoDbUtils
  class CLI < Thor
    
    desc "say_hello NAME", "Says hello"
    def say_hello(name)
      puts MongoDbUtils::Runner.say_hello(name)
    end

  end
end
