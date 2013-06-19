module MongoDbUtils
  module Model

    # A Db stored in the config
    class Db

      URI_NO_USER = /mongodb:\/\/(.*)\/(.*$)/
      URI_USER = /mongodb:\/\/(.*):(.*)@(.*)\/(.*$)/

      attr_accessor :username, :password, :name, :uri

      def initialize(uri)
        user,pwd,host_port,db = nil

        if( uri.match(URI_USER))
          match, user, pwd, host_port, name = *uri.match(URI_USER)
        elsif(uri.match(URI_NO_USER))
          match, host_port, name = *uri.match(URI_NO_USER)
          user = ""
          pwd = ""
        end

        raise "can't parse uri" if( host_port.nil? || name.nil? )

        @host_port = host_port
        @name = name
        @username = user
        @password = pwd
        @uri = uri
      end

      def authentication_required?
        has?(self.username) && has?(self.password)
      end

      # Return the host string in a format that is compatable with mongo binary tools
      # See: http://docs.mongodb.org/manual/reference/program/mongodump/#cmdoption-mongodump--host
      def to_host_s
        "#{@host_port}"
      end

      def to_s_simple
        "#{@name} on #{@host_port} - (#{@username}:#{@password})"
      end

      def <=>(other)
        self.to_s <=> other.to_s
      end

      private
      def has?(s)
        !s.nil? && !s.empty?
      end
    end


    class ReplicaSetDb < Db

      attr_reader :set_name
      def initialize(uri, name)
        super(uri)
        @set_name = name
      end

      # Note: we override this to provide a replica set format
      def to_host_s
        "#{@set_name}/#{@host_port}"
      end

      def to_s
        "[ReplicaSetDb-(#{to_host_s}/#{@name})]"
      end
    end


  end
end
