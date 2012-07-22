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
      say("config::")
      say("dbs:")
      @config.dbs.each do |db|
        say("#{db.to_s_simple}")
      end

      choose do |menu| 
        prep_menu(menu)
        menu.choice "back" do main_menu end
      end
    end

    def add_config
      entry = Hash.new
      entry[:mongo_uri] = ask("Mongo uri (eg: 'mongodb://user:pass@locahost:27017/db')")
      successful = @config.add_db_from_uri(entry[:mongo_uri])

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
          menu.choice "#{db.host}:#{db.port}/#{db.name}" do backup(db) end
        end
      end
    end


    def copy_a_db
      say("not ready yet - goodbye")
    end

    private
    def backup(db)
      puts ">> ..backing up #{db}"
      @cmd.backup(db)
    end

    def prep_menu(menu)
      menu.index = :number
      menu.index_suffix = ") "
      menu.prompt = "?"
    end

  end
end

