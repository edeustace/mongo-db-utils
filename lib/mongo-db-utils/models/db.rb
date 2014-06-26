module MongoDbUtils
  module Model


    # This method accepts 2 possible uri formats
    # 1. the conventional mongo_uri format: mongodb://xxxxxxxx
    # 2. the non standard way of representing a replicaset uri:
    # --> replica_set|mongo_uri
    # --> Eg: my-set|mongodb://xxxxxxx
    # This is useful because many mongo commands require the set name
    # when invoking them and this bundles the 2 things together
    def self.db_from_uri(uri)
      if(uri.include? "|")
        split = uri.split("|")
        ReplicaSetDb.new(split[1], split[0])
      else
        Db.new(uri)
      end
    end

    # A Db stored in the config
    class Db

      URI_NO_USER = /mongodb:\/\/(.*)\/(.*$)/
      URI_USER = /mongodb:\/\/(.*):(.*)@(.*)\/(.*$)/

      attr_reader :username, :password, :name, :uri

      def initialize(uri)
        @uri = uri

        host_port
      end

      def authentication_required?
        has?(self.username) && has?(self.password)
      end

      def host
        host_and_port[:host]
      end

      def port
        host_and_port[:port]
      end



      # Return the host string in a format that is compatable with mongo binary tools
      # See: http://docs.mongodb.org/manual/reference/program/mongodump/#cmdoption-mongodump--host
      def to_host_s
        "#{host_port}"
      end

      def to_s_simple
        "#{name} on #{host_port} - (#{username}:#{password})"
      end

      def to_s
        "[SingleDb-(#{to_host_s}/#{name})]"
      end

      def <=>(other)
        self.to_s <=> other.to_s
      end

      def host_port; bits[:host_port]; end
      def name; bits[:name]; end
      def username; bits[:username]; end
      def password; bits[:password]; end

      private

      # extract the bits out of the uri
      # @return a hash of the bits
      def bits
        user,pwd,host_port,db = nil
        if(@uri.match(URI_USER))
          match, user, pwd, host_port, name = *@uri.match(URI_USER)
        elsif(uri.match(URI_NO_USER))
          match, host_port, name = *@uri.match(URI_NO_USER)
          user = ""
          pwd = ""
        end

        raise "can't parse uri" if( host_port.nil? || name.nil? )

        {
          :host_port => host_port,
          :name => name,
          :username => user,
          :password => pwd
        }

      end

      def has?(s)
        !s.nil? && !s.empty?
      end


      def host_and_port
        match, host,port = *host_port.match(/(.*):(.*)/)
        { :host => host, :port => port }
      end
    end


    class ReplicaSetDb < Db

      attr_reader :set_name
      def initialize(uri, name)
        super(uri)
        @set_name = name
      end


      # Return an array of host:port strings
      def hosts
        host_port.split(",")
      end

      # Block usage of this method from the super
      def host
        raise "'host' is not a valid method for a ReplicaSetDb - use 'hosts' instead."
      end

      # Block usage of this method from the super
      def port
        raise "'port' is not a valid method for a ReplicaSetDb - use 'hosts' instead."
      end

      # Note: we override this to provide a replica set format
      def to_host_s
        "#{@set_name}/#{host_port}"
      end

      def to_s
        "[ReplicaSetDb-(#{to_host_s}/#{name})]"
      end
    end


  end
end
