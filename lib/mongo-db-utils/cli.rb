require 'thor'
require 'mongo-db-utils'
require 'mongo-db-utils/version'
require 'mongo-db-utils/models'
require 'highline/import'

module MongoDbUtils
  class CLI < Thor

    desc "console", "run the console"
    def console
      puts "==================================="
      puts "Mongo Db Utils - Version: #{MongoDbUtils::VERSION}"
      puts "==================================="

      puts "loading config..."

      
      @config = MongoDbUtils::Model::Config.load
      main_menu
    end

    def main_menu
      say("\nWhat do you want to do?")
      choose do |menu|
        prep_menu(menu)
        menu.choice "copy a db" do copy_a_db end
        menu.choices "backup a db" do do_backup end
        menu.choice "remove config" do remove_config end
        menu.choice "add server to config" do add_config end
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

    def add_config
      entry = Hash.new
      entry[:server] = ask("Server (host:port)") do |s|
        s.case = :down
        s.validate = /[a-z|\.]*:[0-9]*/
      end

      entry[:username] = ask("Username")
      entry[:password] = ask("Password")

      successful = @config.add_server(entry[:server], entry[:username], entry[:password]) 
      if successful
        say("added server")
        choose do |menu|
          prep_menu(menu)
          menu.choice "add another?" do add_config end
          menu.choice "done" do main_menu end
        end

      else
        say("couldn't add server")
      end
    end


    def list_dbs
      @dbs = MongoDbUtils::Connector.list_dbs(@config.servers)
      say("Which db?")
      choose do |menu|
        prep_menu(menu)

        @dbs.each do |db|
          db[:names].each do |name|
          server = db[:server]
          menu.choice "#{name}@#{server.host}:#{server.port}" do backup(name, server) end
          end
        end
      end
    
    end


    def copy_a_db
      say("not ready yet - goodbye")
    end
  
    private
    def backup(db, server)
      puts "...backing up #{db}@#{server}"
      MongoDbUtils::Connector.backup(db,server)
    end

    def prep_menu(menu)
      menu.index = :number
      menu.index_suffix = ") "
      menu.prompt = "?"
    end



  end
end
