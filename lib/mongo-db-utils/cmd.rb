require 'mongo-db-utils/cmd/mongotools'
require 'mongo'
require 'mongo/connection'

module MongoDbUtils
  class Cmd

    def self.backup(db, folder, final_path = nil, tar_it = true)
      puts ">> Backing up: #{db}, #{folder}, #{final_path}"
      unless( db_exists?(db) )
        return false
      end

      if( final_path.nil? )
        out_path = "#{folder}/#{db.host}_#{db.port}/#{db.name}/#{timestamp}"
      else
        out_path = "#{folder}/#{final_path}"
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
        "#{full_path}/#{db.name}.tar"
      else
        "#{full_path}/#{db.name}"
      end
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
    def self.copy(path, source, destination, halt_on_no_backup = true)

      backup_made = backup(destination, path)

      if( !backup_made && halt_on_no_backup)
        puts "aborting - no backup was made"
        return
      end

      tmp_path = "~/.mongo-db-utils/tmp"

      FileUtils.mkdir_p(tmp_path)

      puts "backup to: #{tmp_path}/#{source.name}"
      tmp_dump_path = backup(source,tmp_path, source.name, false)

      username = destination.username
      password = destination.password

      # if the destination db doesn't exist
      # we assume that the user has admin control of the server
      # eg its a local server (this needs to be thought through a bit more)
      if( !db_exists?(destination) )
        username = ""
        password = ""
      end

      MongoDbUtils::Commands::MongoTools.restore(
        destination.host,
        destination.port,
        destination.name,
        "#{tmp_dump_path}",
        username,
        password)

      `rm -fr #{tmp_path}`
    end

     def self.backup_s3(backup_folder, db, bucket_name, access_key_id, secret_access_key)
      tar_file = MongoDbUtils::Cmd.backup(db, backup_folder)
      name = tar_file.gsub(File.expand_path(backup_folder), "")
      MongoDbUtils::S3::put_file(tar_file, name, bucket_name, access_key_id, secret_access_key)
      file = File.basename(tar_file)
      folder = tar_file.gsub(file, "")
      `rm -fr #{folder}`
    end


    private

    def self.timestamp
      t = Time.new
      t.strftime("%Y.%m.%d__%H.%M")
    end

    def self.db_exists?(db)
      puts "DB exists? #{db.to_s}"
      connection = Mongo::Connection.from_uri(db.to_s)
      exists = true
      begin
        connection.ping
      rescue Mongo::AuthenticationError => e
        exists = false
      end
      connection.close
      exists
    end
=begin
       connection.database_names 
      rescue Mongo::OperationFailure => e
=end


  end
end
