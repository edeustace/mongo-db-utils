require 'thor'
require 'mongo-db-utils/config-loader'
require 'mongo-db-utils/cmd'
require 'mongo-db-utils/console'

module MongoDbUtils
  class CLI < Thor

    desc "console", "run the console"
    def console
      @config = MongoDbUtils::ConfigLoader.load
      console = MongoDbUtils::Console.new(@config, MongoDbUtils::Cmd)
      console.run
    end
  end
end
