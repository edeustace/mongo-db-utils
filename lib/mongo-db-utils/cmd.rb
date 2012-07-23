require 'mongo-db-utils/cmd/mongotools'
require 'mongo'
require 'mongo/connection'

module MongoDbUtils
  class Cmd

    def self.backup(db, folder, final_path = nil, tar_it = true)
      puts "--"
      puts ">> Backing up: #{db}, #{folder}, #{final_path}"
      unless( db_exists?(db) )
        return false
      end

      t = Time.new
      timestamp = t.strftime("%Y.%m.%d__%H.%M")

      if( final_path.nil? )
        out_path = "#{folder}/#{db.host}_#{db.port}/#{db.name}/#{timestamp}"
      else
        puts "final path not nil out_path: #{out_path}"
      end

      full_path = File.expand_path(out_path)

      puts ">> final backup path: #{full_path}"

      FileUtils.mkdir_p(full_path)
      MongoDbUtils::Commands::MongoTools.dump(
        db.host,
        db.port,
        db.name,
        full_path,
        db.username,
      db.password)

      if( tar_it )
        Dir.chdir(full_path)
        `tar cvf #{db.name}.tar #{db.name}`
        `rm -fr #{full_path}/#{db.name}`
      end

      "#{full_path}/#{db.name}.tar"
    end

    # With remote dbs you can't do a copy_database if you're not an admin.
    # so using restore instead
    #  connection = Mongo::Connection.from_uri(destination.to_s)
    # mongo_db = connection[destination.name]
    # if( destination.authentication_required? )
    #  login_result = mongo_db.authenticate(destination.username, destination.password)
    # end
    # host = "#{source.host}:#{source.port}"
    # connection.copy_database(source.name, destination.name, host, source.username, source.password)
    #
    #
    def self.copy(path, source, destination, halt_on_no_backup = true)

      backup_made = self.backup(destination, path)

      if( !backup_made && halt_on_no_backup)
        puts "aborting - no backup was made"
        return
      end

      tmp_path = "~/.mongo-db-utils/tmp"

      FileUtils.mkdir_p(tmp_path)

      puts "backup to: #{tmp_path}/#{source.name}"
      backup(source,tmp_path, source.name, false)

      MongoDbUtils::Commands::MongoTools.restore(
        destination.host,
        destination.port,
        destination.name,
        "#{tmp_path}/#{source.name}/#{source.name}",
        destination.username,
      destination.password)

      `rm -fr #{tmp_path}`
    end


    private
    def self.db_exists?(db)

      puts "DB exists? #{db.to_s}"

      connection = Mongo::Connection.from_uri(db.to_s)
      mongo_db = connection[db.name]

      exists = !mongo_db.nil?

      puts "mongo_db: #{mongo_db}"
      if( db.authentication_required? && exists )
        login_result = mongo_db.authenticate(db.username, db.password)
        exists = !login_result.nil?
      else
      end
      connection.close
      exists
    end

    def self.remove_db(db)
      if( db_exists?(db))
        connection = Mongo::Connection.from_uri(db.to_s)
        if( db.authentication_required? )
          mongo_db = connection[db.name]
          mongo_db.authenticate(db.username, db.password)
        end

        connection.drop_database(db.name)
        connection.close
      end
    end
  end
end
