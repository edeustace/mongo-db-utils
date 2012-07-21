require "mongo-db-utils/version"
require 'yaml'
require 'fileutils'
require 'mongo'

module MongoDbUtils

    class Connector
      ###
      # We don't add the names to the server as we don't want that data stored.
      ###
      def self.list_dbs(servers)
        result = []
        servers.each do |server|
          server_dbs = Hash.new
          server_dbs[:server] = server
          uri = self.make_uri(server)
          puts "uri: #{uri}"
          connection = Mongo::Connection.from_uri( uri )
          server_dbs[:names] = connection.database_names
          result << server_dbs
          connection.close
        end
        result
      end

      def self.backup(db,server)
        t = Time.new
        timestamp = t.strftime("%Y.%m.%d__%H.%M")
        out_path = "~/.mongo-db-utils/backups/#{server.host}.#{server.port}/#{db}/#{timestamp}"
        full_path = File.expand_path(out_path)
        FileUtils.mkdir_p(full_path)
        `mongodump -h #{server.host} -db #{db} -o #{full_path}`
        `tar cvf #{full_path}/#{db}.tar.gz #{full_path}/#{db}`
        `rm -fr #{full_path}/#{db}`
      end

      private
      def self.make_uri(server)
        user_pass = ""
        if(!server.username.empty? && !server.password.empty? )
          user_pass = "#{server.username}:#{server.password}@"
        end

        "mongodb://#{user_pass}#{server.host}:#{server.port}"
      end

    end

    module Model
      
      class Config

        attr_reader :servers

        def initialize
          @name = "This is the config"
        end

        def empty?
          @servers.nil? || @servers.empty?
        end

        def flush
          @servers = []
          Config.flush
        end

        def add_server(host,username,password)
          @servers = [] if @servers.nil?
          @servers << Server.new(host,username,password)
          Config.save(self)
          true
        end
        
        def server(name)
          @servers.each do |s|
            return s if s.host == name
          end
          raise "Can't find server with host name: #{name}"
        end


        def self.load( load_path = ".mongo-db-utils/config.yml")
          full_path = self.expand(load_path)
          puts "loading config from #{full_path}"
          
          if File.exist?(full_path)
            YAML.load(File.open(full_path))
          else
            Config.initialize_files(full_path)
            config = Config.new
            puts "writing config to: #{full_path}"
            File.open( full_path, 'w' ) do |out|
              YAML.dump( config, out )
            end
            config
          end
        end

        def self.flush( path = ".mongo-db-utils/config.yml" )
          puts "flush ---"
          path = self.expand(path)
          puts "removing: #{path}"
          FileUtils.rm(path) if File.exist?(path)
          puts "flush::success? #{!File.exist?(path)}"
          self.initialize_files(path)
        end
        
        def self.save(config, path = ".mongo-db-utils/config.yml")
          self._save(config, self.expand(path))
        end

        def to_s
          "Config::"
        end

        private 
        def self._save(config,full_path)
            File.open( full_path, 'w' ) do |out|
              YAML.dump( config, out )
            end
        end


        def self.get_folder_name(path)
            /(.*)\/.*.yml/.match(path)[1]
        end

        def self.initialize_files(path)
            folder = self.get_folder_name(path)
            FileUtils.mkdir_p(folder) unless File.exist?(folder)
            FileUtils.touch(path)
        end
        
        def self.expand(p)
          File.expand_path("~/#{p}")
        end



      end

      class Server
        attr_accessor :host, :username, :password, :port

        def initialize(host_and_port,username,password)
          match = /(.*):(.*)/.match(host_and_port)
          @host = match[1]
          @port = match[2]
          @username = username
          @password = password
        end

        def to_s
          "#{host}:#{port}"
        end


      end

    end

end
