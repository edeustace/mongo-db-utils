require 'highline/import'
require 'mongo-db-utils/version'
Dir['lib/mongo-db-utils/models/*.rb'].each { |file| require file.gsub("lib/", "") }


module MongoDbUtils

  # This is a workaround for this issue:
  # https://github.com/JEG2/highline/issues/69
  # In ruby 2 + highline the yaml strings don't get serialized correctly.
  # The workaround is for any argument that is of type HighLine::String to call to_s on it
  class ConfigProxy

    def initialize(config)
      @config = config
    end

    protected
    def method_missing(name, *args, &block)
      cleaned_args = args.map { |a| trim(clean(a)) }
      cleaned_args.each { |a| puts "#{a} -> #{a.class}" }
      @config.send(name, *cleaned_args, &block)
    end

    def clean(a)
      if a.class.to_s == "HighLine::String"
        a.to_s
      else
        a
      end
    end

    def trim(s)
      if (s.class.to_s == "String")
        s.strip
      else
        s
      end
    end
  end


  class Console

    HEADER = <<-eos
=====================================
|| Mongo Db Utils - Version: #{MongoDbUtils::VERSION} ||
=====================================
    eos


    def initialize(config, cmd)
      @config = ConfigProxy.new(config)
      @cmd = cmd
    end

    def run
      say(HEADER)
      say(MongoDbUtils::READY_FOR_USE)
      main_menu
    end

    private
    def main_menu

      my_menu("What do you want to do?") do |menu|
        menu.choice "copy a db" do
          copy_a_db
        end
        menu.choice "backup a db locally" do
          do_backup
        end
        menu.choice "backup a db to an amazon s3 bucket" do
          backup_to_s3
        end
        menu.choice "download a backup from an amazon s3 bucket" do
          download_backup_from_s3
        end
        menu.choice "delete a backup from the downloads" do
          delete_downloaded_backup
        end
        menu.choice "restore a db from a downloaded backup" do
          restore_db_from_backup
        end
        menu.choice "remove config" do
          remove_config
        end
        menu.choice "show config" do
          show_config
        end
        menu.choice "add db server to config" do
          add_config
        end
        menu.choice "add Amazon bucket to config" do
          add_bucket_to_config
        end
        menu.choice "remove db server from config" do
          remove_server_from_config
        end
      end
    end

    def remove_config
      @config.flush
      main_menu
    end

    #
    def do_backup
      if @config.empty?
        get_config
      else
        db_list_menu("Choose a DB:") do |db|
          @cmd.backup(db, @config.backup_folder)
        end
      end
    end


    def backup_to_s3
      plan = Hash.new

      db_list_menu("Choose a DB:") do |db|
        plan[:db] = db
      end

      if @config.has_buckets?
        bucket_list_menu("Choose a Bucket:") do |bucket|
          plan[:bucket] = bucket
        end
      else
        say("You don't have any buckets yet - add one..")
        add_bucket_to_config
        return
      end

      @cmd.backup_s3(
        @config.backup_folder,
        plan[:db],
        plan[:bucket].name,
        plan[:bucket].access_key,
        plan[:bucket].secret_key)
    end


    def download_backup_from_s3
      plan = Hash.new

      if @config.has_buckets?
        bucket_list_menu("Choose a source bucket:", true) do |bucket|
          if bucket == 'back'
            main_menu
            return
          end
          plan[:bucket] = bucket
        end
      else
        say("You don't have any buckets yet - add one..")
        add_bucket_to_config
        return
      end

      backups = @cmd.list_backups(
        plan[:bucket].name,
        plan[:bucket].access_key,
        plan[:bucket].secret_key).select { |a| a.end_with? ".tgz" }

      backup_list_menu("Choose a backup:", backups, true) do |backup|
        if backup == 'back'
          main_menu
        else
          plan[:backup] = backup
          @cmd.download_backup_from_s3(
            @config.backup_folder,
            plan[:backup],
            plan[:bucket].name,
            plan[:bucket].access_key,
            plan[:bucket].secret_key)
        end
      end
    end


    def delete_downloaded_backup
      plan = Hash.new

      downloaded_backups_list_menu("Choose a backup:", @cmd.list_downloaded_backups(@config.backup_folder), true) do |backup|
        if backup == 'back'
          main_menu
          return
        end
        if ask("Delete backup #{backup}? (Y|n) [n]") != 'Y'
          main_menu
          return
        end
        plan[:backup] = backup
        @cmd.delete_backup(
          @config.backup_folder,
          plan[:backup])
      end
    end


    def restore_db_from_backup
      plan = Hash.new

      db_list_menu("Choose a target DB:") do |db|
        plan[:db] = db
      end

      downloaded_backups_list_menu("Choose a backup:", @cmd.list_downloaded_backups(@config.backup_folder)) do |backup|
        plan[:backup] = backup
      end

      source_db_list_menu("Choose a source_db in the backup:", @cmd.list_backup_folders(@config.backup_folder, plan[:backup])) do |folder|
        plan[:source_db] = folder
      end

      if ask("Restore db #{db}? (Y|n) [n]") != 'Y'
        main_menu
        return
      end

      @cmd.restore_from_backup(
        @config.backup_folder,
        plan[:db],
        plan[:backup],
        plan[:source_db])
    end

    def add_bucket_to_config
      say("add an amazon bucket:")
      bucket = MongoDbUtils::Model::Bucket.new

      bucket.name = ask("Name")
      bucket.access_key = ask("Access Key")
      bucket.secret_key = ask("Secret Key")

      @config.add_bucket(bucket)

      say("Bucket added")
      my_menu("")
    end

    def get_config
      say("You don't have any servers configured, please add one:")
      add_config
    end

    def show_config
      say("Config")
      say("--------------------")
      say("dbs:")
      say("--------------------")
      @config.dbs.sort.each do |db|
        say(db.to_s_simple)
      end
      say("--------------------")
      say("Amazon S3 Buckets")
      if (@config.buckets.nil?)
        say("no buckets")
      else
        @config.buckets.sort.each do |bucket|
          say(bucket.to_s)
        end
      end

      say("backups folder:")
      say("--------------------")
      say("#{@config.backup_folder}")
      say("--------------------")
      my_menu("")
    end

    def add_config
      my_menu("Single db or replica set?") do |menu|
        menu.choice "single db" do
          add_single_db
        end
        menu.choice "replica set db" do
          add_replica_set
        end
      end
    end

    def add_single_db
      mongo_uri = ask("Mongo uri (eg: 'mongodb://user:pass@locahost:27017/db')")
      new_uri = mongo_uri.to_s.strip
      successful = @config.add_single_db(new_uri)

      say("bad uri!") unless successful

      label = successful ? "add another?" : "try again?"

      my_menu("") do |menu|
        menu.choice label do
          add_config
        end
      end
    end

    def add_replica_set
      mongo_uri = ask("Replica Set uri: (eg: mongodb://user:pass@host1:port,host2:port,.../db)1
")
      replica_set_name = ask("Replica Set name: ")

      successful = @config.add_replica_set(mongo_uri, replica_set_name)

      say("bad replica set uri") unless successful

      my_menu("") do |menu|
        menu.choice (successful ? "add another" : "try again?") do
          add_config
        end
      end
    end

    def remove_server_from_config
      db_list_menu("Remove server from config:") do |db|
        @config.remove_db(db)
        remove_server_from_config
      end
    end

    def copy_a_db
      copy_plan = Hash.new
      db_list_menu("Choose db to copy:") do |db|
        copy_plan[:source] = db
      end
      db_list_menu("Choose a destination:") do |db|
        copy_plan[:destination] = db
      end
      show_copy_plan(copy_plan)
    end

    def show_copy_plan(plan)
      say("Copy: (we'll backup the destination before we copy)")
      say("#{plan[:source].to_s} --> #{plan[:destination].to_s}")

      my_menu("") do |menu|
        menu.choice "Do it!" do
          begin_copy(plan, false)
        end
        menu.choice "Do it - skip backup" do
          begin_copy(plan, true)
        end
        menu.choice "Reverse" do
          show_copy_plan({:source => plan[:destination], :destination => plan[:source]})
        end
      end
    end

    def begin_copy(plan, skip_backup = false)
      @cmd.copy(@config.backup_folder, plan[:source], plan[:destination], false, skip_backup)
    end

    def my_menu(prompt, show_defaults = true)
      say(prompt)
      choose do |menu|
        menu.shell = true
        menu.index = :number
        menu.prompt = "\n#{prompt}\n"
        menu.index_suffix = ") "
        menu.prompt = "?"
        if (show_defaults)
          menu.choice "Back" do
            main_menu
          end
          menu.choice "Exit" do
            say("Goodbye"); abort("--");
          end
        end
        say("")
        yield menu if block_given?
      end
    end

    def db_list_menu(prompt)
      my_menu(prompt, false) do |menu|
        @config.dbs.sort.each do |db|
          menu.choice "#{db.to_s_simple}" do
            yield db if block_given?
          end
        end
      end
    end

    def bucket_list_menu(prompt, show_defaults = false)
      my_menu(prompt, false) do |menu|
        if show_defaults
          menu.choice 'Back' do
            yield 'back' if block_given?
          end
        end
        @config.buckets.sort.each do |bucket|
          menu.choice "#{bucket}" do
            yield bucket if block_given?
          end
        end
      end
    end

    def backup_list_menu(prompt, backups, show_defaults = false)
      my_menu(prompt, false) do |menu|
        if show_defaults
          menu.choice 'Back' do
            yield 'back' if block_given?
          end
        end
        menu.choice 'latest' do
          yield 'latest' if block_given?
        end
        backups.sort.each do |backup|
          menu.choice "#{backup}" do
            yield backup if block_given?
          end
        end
      end
    end

    def source_db_list_menu(prompt, folders)
      my_menu(prompt, false) do |menu|
        folders.sort.each do |item|
          menu.choice "#{item}" do
            yield item if block_given?
          end
        end
      end
    end

    def downloaded_backups_list_menu(prompt, backups, show_defaults = false)
      my_menu(prompt, false) do |menu|
        if show_defaults
          menu.choice 'Back' do
            yield 'back' if block_given?
          end
        end
        backups.sort.each do |item|
          menu.choice "#{item}" do
            yield item if block_given?
          end
        end
      end
    end


    private
    def clean(s)
      s.to_s.strip
    end

  end
end
