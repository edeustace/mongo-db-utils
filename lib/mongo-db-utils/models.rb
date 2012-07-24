module MongoDbUtils

  module Model
    class Config
      attr_reader :dbs, :buckets
      attr_writer :writer
      attr_accessor :backup_folder

      def initialize
        @dbs = []
        @buckets = []
      end
      
      def empty?
        @dbs.nil? || @dbs.empty?
      end

      def has_buckets?
        !@buckets.nil? && !@buckets.empty?
      end


      def flush
        @dbs = []
        @writer.flush
      end

      def remove_db(db)
        @dbs = @dbs - [db]
        @writer.save(self)
      end

      def add_db_from_uri(uri)
        @dbs = [] if @dbs.nil?
        db = Db.from_uri(uri)
        unless db.nil? || already_contains(db)
          @dbs << db
          @dbs.sort!
          @writer.save(self)
        end
        !db.nil?
      end

      def already_contains(db)
        @dbs.each do |existing|
          if( existing.to_s == db.to_s)
            return true
          end

          if( existing.host == db.host && existing.name == db.name)
            return true
          end

        end
        return false
      end

      # because we are serializing the config - the bucket may be nil
      # at this point
      def add_bucket(bucket)
        @buckets = [] if @buckets.nil?
        unless bucket.nil? || already_contains_bucket?(bucket)
          @buckets << bucket
          @writer.save(self)
        end
      end

      def already_contains_bucket?(bucket)
        puts "@buckets: #{@buckets}"
        @buckets.each do |b|
          if( b.to_s == bucket.to_s )
            return true
          end
        end
        return false
      end


      def save
        @writer.save(self)
      end

      def to_s
        "Config"
      end
    end

    class Bucket
      attr_accessor :name, :access_key, :secret_key

      def to_s
        "#{name} | #{access_key} | #{secret_key}"
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

      def authentication_required?
        has?(self.username) && has?(self.password)
      end

      def has?(s)
        !s.nil? && !s.empty?
      end


      def to_s
        user_pass = ""
        unless(@username.empty? || @password.empty? )
          user_pass = "#{@username}:#{@password}@"
        end
        "mongodb://#{user_pass}#{@host}:#{@port}/#{@name}"
      end

      def to_s_simple
        "#{@name} on #{@host}:#{@port} - (#{@username}:#{@password})"
      end

      def <=>(other)
        self.to_s <=> other.to_s
      end

    end
  end
end
