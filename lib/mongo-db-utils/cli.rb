require 'thor'
require 'mongo-db-utils/config-loader'
require 'mongo-db-utils/cmd'
require 'mongo-db-utils/console'
require 'mongo-db-utils/models'
require 'mongo-db-utils/s3'

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


    desc "backup_s3 MONGO_URI BUCKET ACCESS_KEY SECRET_ACCESS_KEY", "backup a db to Amason s3 with a mongo uri eg: mongodb://user:pass@server:port/dbname"
    def backup_s3(mongo_uri, bucket_name, access_key_id, secret_access_key)
      @config = MongoDbUtils::ConfigLoader.load
      db = MongoDbUtils::Model::Db.from_uri(mongo_uri)
      raise "can't parse uri" if db.nil?
      tar_file = MongoDbUtils::Cmd.backup(db, @config.backup_folder)

      name = tar_file.gsub(File.expand_path(@config.backup_folder), "")

      MongoDbUtils::S3::put_file(tar_file, name, bucket_name, access_key_id, secret_access_key)
      file = File.basename(tar_file)
      folder = tar_file.gsub(file, "")
      `rm -fr #{folder}`
    end

  end
end
