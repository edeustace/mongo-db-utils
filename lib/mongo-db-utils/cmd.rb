require 'mongo-db-utils/tools/commands'
require 'mongo'

module MongoDbUtils
  class Cmd

    include MongoDbUtils::Tools

    def self.backup(db, folder, final_path = nil, tar_it = true)
      puts ">> Backing up: #{db}, #{folder}, #{final_path}"
      unless (db_exists?(db))
        return false
      end

      if (final_path.nil?)
        out_path = File.join(folder, db.to_host_s, db.name, timestamp)
      else
        out_path = File.join(folder, final_path)
      end

      full_path = File.expand_path(out_path)

      puts ">> final backup path: #{full_path}"

      FileUtils.mkdir_p(full_path)

      Dump.new(
        db.to_host_s,
        db.name,
        full_path,
        db.username,
        db.password).run

      full_db_path = File.join(full_path, db.name)

      if (tar_it)
        Dir.chdir(full_path)
        `tar --create --verbose --file=#{db.name}.tar #{db.name}`
        delete_folder full_db_path
        "#{full_db_path}.tar"
      else
        full_db_path
      end
    end

    # With remote dbs you can't do a copy_database if you're not an admin.
    def self.copy(path, source, destination, halt_on_no_backup = true, skip_backup = false)

      backup_made = if skip_backup
                      true
                    else
                      backup(destination, path)
                    end

      if !backup_made && halt_on_no_backup
        puts 'aborting - no backup was made'
        return
      end

      tmp_path = File.join(ConfigLoader::CONFIG_LOCATION, 'tmp')

      FileUtils.mkdir_p(tmp_path)

      puts "backup to: #{File.join(tmp_path, source.name)}"
      tmp_dump_path = backup(source, tmp_path, source.name, false)

      # if the destination db doesn't exist
      # we assume that the user has admin control of the server
      # eg its a local server (this needs to be thought through a bit more)
      username = ''
      password = ''

      if db_exists? destination
        username = destination.username
        password = destination.password
      end

      Restore.new(
        destination.to_host_s,
        destination.name,
        "#{tmp_dump_path}",
        username,
        password).run

      delete_folder tmp_path
    end

    def self.backup_s3(backup_folder, db, bucket_name, access_key_id, secret_access_key)
      tar_file = MongoDbUtils::Cmd.backup(db, backup_folder)
      name = tar_file.gsub(File.expand_path(backup_folder), '')
      MongoDbUtils::S3::put_file(tar_file, name, bucket_name, access_key_id, secret_access_key)
      file = File.basename(tar_file)
      folder = tar_file.gsub(file, '')
      delete_folder folder
    end

    def self.list_backups(bucket_name, access_key_id, secret_access_key)
      MongoDbUtils::S3::list_bucket(bucket_name, access_key_id, secret_access_key)
    end

    def self.list_downloaded_backups(backup_folder)
      Dir.entries(backup_folder).select { |a| a.end_with? '.tgz' }
    end

    def self.list_backup_folders(backup_folder, backup)
      puts "reading backup folders from #{backup_folder} #{backup}"
      folders = list_archive_folders(backup_folder, backup)
      folders.map { |a| a.slice! File.basename(backup, '.tgz'); a.delete '/' }.select { |a| a != '' }
    end

    def self.download_backup_from_s3(backup_folder, backup, bucket_name, access_key_id, secret_access_key)
      if backup == 'latest'
        backup = get_latest_backup(bucket_name, access_key_id, secret_access_key)
      end
      backup_file = File.join(backup_folder, File.basename(backup))

      puts "download_backup_from_s3 #{backup_file}"
      if File.exists? backup_file
        puts "File downloaded already #{backup_file}"
      else
        FileUtils.mkdir_p(backup_folder)
        puts "Downloading #{backup_file}"
        download_backup(backup_file, backup, bucket_name, access_key_id, secret_access_key)
      end
      backup
    end

    def self.restore_from_backup(backup_folder, db, backup, source_db)
      Dir.mktmpdir do |dir|
        puts "Unzipping archive ..."
        unzip(File.join(backup_folder, backup), dir)
        puts "Restoring db ..."
        restore_db(db, File.join(dir, source_db ))
      end
    end


    def self.delete_backup(backup_folder, backup)
      delete_folder File.join(backup_folder, backup)
    end


    private

    def self.timestamp
      t = Time.new
      t.strftime('%Y.%m.%d__%H.%M')
    end

    def self.db_exists?(db)
      puts "DB exists? #{db.to_s}"
      connection = Mongo::Connection.from_uri(db.uri)
      exists = true
      begin
        connection.ping
      rescue Mongo::AuthenticationError => e
        exists = false
      end
      connection.close
      exists
    end

    def self.download_backup(download_file_name, backup, bucket_name, access_key_id, secret_access_key)
      puts "downloading backup to #{download_file_name} from #{bucket_name} key #{backup}"
      MongoDbUtils::S3::get_file(download_file_name, backup, bucket_name, access_key_id, secret_access_key)
    end

    def self.restore_db(destination, backup)
      puts "restoring db #{destination} from #{backup}"

      # if the destination db doesn't exist
      # we assume that the user has admin control of the server
      # eg its a local server (this needs to be thought through a bit more)
      username = ''
      password = ''

      if db_exists? destination
        username = destination.username
        password = destination.password
      end

      Restore.new(
        destination.to_host_s,
        destination.name,
        backup,
        username,
        password).run
    end

    def self.unzip(archive, dir)
      command = "tar --extract --gzip --file=#{archive} --directory=#{dir} --strip 1"
      output = `#{command} 2>&1`
      raise "#{output} cmd <#{command}>" unless $?.to_i == 0
    end

    def self.list_archive_folders(folder, archive)
      command = "tar --list --file=#{File.join(folder, archive)} | grep '/$'"
      output = `#{command} 2>&1`
      raise "#{output} cmd <#{command}>" unless $?.to_i == 0
      output.split
    end

    def self.get_latest_backup(bucket_name, access_key_id, secret_access_key)
      list_backups(
        bucket_name,
        access_key_id,
        secret_access_key).select { |a| a.end_with? ".tgz" }.sort.pop
    end

    def self.delete_folder(path)
      puts "deleting folder #{path}"
      `rm --force --recursive #{path}`
    end
  end
end
