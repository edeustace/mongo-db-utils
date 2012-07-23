require 'highline/import'
require 'mongo-db-utils/version'
require 'mongo-db-utils/models'

module MongoDbUtils
  class Console

    HEADER = <<-eos
    ===================================
      Mongo Db Utils - Version: #{MongoDbUtils::VERSION}
      ===================================
      eos


    def initialize(config, cmd)
      @config = config
      @cmd = cmd
    end

    def run
      say(HEADER)
      say(MongoDbUtils::READY_FOR_USE)
      main_menu
    end

    private
    def main_menu
      say("\nWhat do you want to do?")
      choose do |menu|
        prep_menu(menu)
        menu.choice "copy a db" do copy_a_db end
        menu.choice "backup a db" do do_backup end
        menu.choice "remove config" do remove_config end
        menu.choice "show config" do show_config end
        menu.choice "add server to config" do add_config end
        menu.choice "remove server from config" do remove_server_from_config end
        menu.choice "exit" do say("goodbye") end
      end
    end

    def remove_config
      @config.flush
      main_menu
    end

    def do_backup

      if @config.empty?
        get_config
      else
        list_dbs
      end
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
        say("#{db.to_s_simple}")
      end
      say("--------------------")
      say("")
      say("backups folder:")
      say("--------------------")
      say("#{@config.backup_folder}")
      say("--------------------")
      choose do |menu|
        prep_menu(menu)
        menu.choice "back" do main_menu end
      end
    end

    def add_config
      entry = Hash.new
      entry[:mongo_uri] = ask("Mongo uri (eg: 'mongodb://user:pass@locahost:27017/db')")
      new_uri = entry[:mongo_uri].gsub(" ", "")
      successful = @config.add_db_from_uri(new_uri)

      if successful
        say("added server")
        choose do |menu|
          prep_menu(menu)
          menu.choice "add another?" do add_config end
          menu.choice "done" do main_menu end
        end

      else
        say("couldn't add uri")
        add_config
      end
    end


    def list_dbs
      say("Which db?")
      choose do |menu|
        prep_menu(menu)
        @config.dbs.each do |db|
          menu.choice "#{db.to_s}" do backup(db) end
        end
        menu.choice "back" do main_menu end
      end
    end


    def remove_server_from_config
      say("remove server from config...")
      choose do |menu|
        prep_menu(menu)
        @config.dbs.sort.each do |db|
          menu.choice "#{db.to_s}" do
            @config.remove_db(db)
            remove_server_from_config
          end
        end
        menu.choice "back" do main_menu end
      end
    end

    def copy_a_db

      copy_plan = Hash.new

      say("Choose db to copy:")
      choose do |menu|
        prep_menu(menu)
        @config.dbs.sort.each do |db|
          menu.choice "#{db.to_s}" do
            copy_plan[:source] = db
          end

        end
        menu.choice "add server to config" do add_config end
        menu.choice "back" do
          main_menu
          return
        end
      end

      say("Choose db destination:")
      choose do |menu|
        prep_menu(menu)
        @config.dbs.sort.each do |db|
          menu.choice "#{db.to_s}" do
            copy_plan[:destination] = db
          end unless db == copy_plan[:source]
        end
        menu.choice "add server to config" do add_config end
      end
      show_copy_plan(copy_plan)
    end

    def show_copy_plan(plan)
      say("Copy: (we'll backup the destination before we copy)")
      say("#{plan[:source].to_s} --> #{plan[:destination].to_s}")

      choose do |menu|
        prep_menu(menu)
        menu.choice "Begin" do begin_copy(plan) end
        menu.choice "Reverse" do
          show_copy_plan( {:source => plan[:destination], :destination => plan[:source]})
        end
        menu.choice "Back" do main_menu end
      end
    end

    def begin_copy(plan)
      say("doing copy...")
      @cmd.copy(@config.backup_folder, plan[:source], plan[:destination], false)
    end

    private
    def backup(db)
      puts ">> ..backing up #{db}"
      @cmd.backup(db, @config.backup_folder)
    end

    def prep_menu(menu)
      menu.index = :number
      menu.index_suffix = ") "
      menu.prompt = "?"
    end

  end
end
