require 'mongo-db-utils/cmd/mongotools'
require 'mongo'
require 'mongo/connection'

module MongoDbUtils
  class Cmd

    def self.backup(db, path)

      unless( db_exists?(db) )
        return false
      end

      t = Time.new
      timestamp = t.strftime("%Y.%m.%d__%H.%M")
      out_path = "#{path}/#{db.host}_#{db.port}/#{db.name}/#{timestamp}"
      full_path = File.expand_path(out_path)

      FileUtils.mkdir_p(full_path)
      MongoDbUtils::Commands::MongoTools.dump(db.host,db.port,db.name,full_path,db.username,db.password)

      `tar cvf #{full_path}/#{db.name}.tar.gz #{full_path}/#{db.name}`
      `rm -fr #{full_path}/#{db.name}`
      true
    end

    def self.copy(path, source, destination, halt_on_no_backup = true)

      backup_made = self.backup(destination, path)


      if( !backup_made && halt_on_no_backup)
        puts "aborting - no backup was made"
        return
      end

      remove_db(destination)
      puts "copying... please wait..."
      connection = Mongo::Connection.from_uri(destination.to_s)
      source_server = "#{source.host}:#{source.port}"
      connection.copy_database(source.name,destination.name,source_server,source.username, source.password)
      connection.close
    end


    private
    def self.db_exists?(db)
      connection = Mongo::Connection.from_uri(db.to_s)
      contains_db = connection.database_names.include?(db.name)
      connection.close
      contains_db
    end

    def self.remove_db(db)
      connection = Mongo::Connection.from_uri(db.to_s)
      if( connection.database_names.include?(db.name))
        connection.drop_database(db.name)
      end
      connection.close
    end
  end
end
