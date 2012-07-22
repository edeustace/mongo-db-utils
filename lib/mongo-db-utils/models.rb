module MongoDbUtils

  module Model
    class Config
      attr_reader :dbs
      attr_writer :writer
      attr_accessor :backup_folder

      def initialize
        @dbs = []
      end
      
      def empty?
        @dbs.nil? || @dbs.empty?
      end

      def flush
        @dbs = []
        @writer.flush
      end

      def add_db_from_uri(uri)
        @dbs = [] if @dbs.nil?
        db = Db.from_uri(uri)
        unless db.nil?
          @dbs << db
          @writer.save(self)
        end
        !db.nil?
      end

      def save
        @writer.save(self)
      end

      def to_s
        "Config"
      end
    end


    # A Db stored in the config
    class Db

      URI_NO_USER = /mongodb:\/\/(.*):(.*)\/(.*$)/
      URI_USER = /mongodb:\/\/(.*):(.*)@(.*):(.*)\/(.*$)/

      attr_accessor :host, :username, :password, :port, :name

      def initialize(name, host, port, username=nil, password=nil)
        @host = host
        @port = port
        @name = name
        @username = username
        @password = password
      end

      def self.from_uri(uri)

        user,pwd,host,port,db = nil

        if( uri.match(URI_USER))
          match, user, pwd, host, port, name = *uri.match(URI_USER)
        elsif(uri.match(URI_NO_USER))
          match, host, port, name = *uri.match(URI_NO_USER)
          user = ""
          pwd = ""
        end

        return nil if( host.nil? || port.nil? || name.nil? )

        Db.new(name,host,port,user,pwd)
      end


      def to_s
        user_pass = ""
        unless(@username.empty? || @password.empty? )
          user_pass = "#{@username}:#{@password}@"
        end
        "mongodb://#{user_pass}#{@host}:#{@port}/#{@name}"
      end

      def to_s_simple
        "#{@host}:#{@port}/#{@name}"
      end
    end
  end
end
