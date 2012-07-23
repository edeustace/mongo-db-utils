require 'thor'
require 'mongo-db-utils/config-loader'
require 'mongo-db-utils/cmd'
require 'mongo-db-utils/console'
require 'mongo-db-utils/models'

module MongoDbUtils
  class CLI < Thor

    desc "console", "run the interactive console"
    def console
      @config = MongoDbUtils::ConfigLoader.load
      console = MongoDbUtils::Console.new(@config, MongoDbUtils::Cmd)
      console.run
    end

    desc "backup MONGO_URI", "backup a db with a mongo uri eg: mongodb://user:pass@server:port/dbname"
    def backup(mongo_uri)
      @config = MongoDbUtils::ConfigLoader.load
      db = MongoDbUtils::Model::Db.from_uri(mongo_uri)
      raise "can't parse uri" if db.nil?
      MongoDbUtils::Cmd.backup(db, @config.backup_folder)
    end
  end
end
