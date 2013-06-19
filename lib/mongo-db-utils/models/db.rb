module MongoDbUtils
  module Model

    # A Db stored in the config
    class Db

      URI_NO_USER = /mongodb:\/\/(.*)\/(.*$)/
      URI_USER = /mongodb:\/\/(.*):(.*)@(.*)\/(.*$)/

      attr_accessor :host_port, :username, :password, :name, :uri

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

      def to_host_format
        "#{@set_name}/#{@host_port}"
      end
    end


  end
end
