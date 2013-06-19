require 'thor'
require 'mongo-db-utils/config-loader'
require 'mongo-db-utils/cmd'
require 'mongo-db-utils/console'

Dir['lib/mongo-db-utils/models/*.rb'].each {|file| require file.gsub("lib/", "") }
require 'mongo-db-utils/s3'

module MongoDbUtils
  class CLI < Thor

    desc "console", "run the interactive console @param path - path to config file"
    def console(path = MongoDbUtils::ConfigLoader::CONFIG_LOCATION)

      if File.extname(path) != ".yml"
        puts "Error: You must use a yaml file as your config file location"
      else
        @loader = MongoDbUtils::ConfigLoader.new(path)
        @config = @loader.config
        console = MongoDbUtils::Console.new(@config, MongoDbUtils::Cmd)
        console.run
      end
    end

    desc "backup MONGO_URI", "backup a db with a mongo uri eg: mongodb://user:pass@server:port/dbname"
    def backup(mongo_uri, replica_set_name = nil)
      @config = MongoDbUtils::ConfigLoader.load

      db = get_db(mongo_uri, replica_set_name)
      raise "can't parse uri" if db.nil?
      MongoDbUtils::Cmd.backup(db, @config.backup_folder)
    end


    desc "backup_s3 MONGO_URI BUCKET ACCESS_KEY SECRET_ACCESS_KEY", "backup a db to Amason s3 with a mongo uri eg: mongodb://user:pass@server:port/dbname"
    def backup_s3(mongo_uri, bucket_name, access_key_id, secret_access_key, replica_set_name = nil)
      @config = MongoDbUtils::ConfigLoader.load
      backup_folder = @config.backup_folder
      db = get_db(mongo_uri, replica_set_name)
      raise "can't parse uri" if db.nil?
      MongoDbUtils::Cmd.backup_s3(backup_folder, db, bucket_name, access_key_id, secret_access_key)
    end

    private
    def get_db(uri, name = nil)
      if(name.nil?)
        MongoDbUtils::Model::Db.new(uri)
      else
        MongoDbUtils::Models::ReplicaSetDb.new(uri, name)
      end
    end

  end
end
