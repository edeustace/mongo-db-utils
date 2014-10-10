require 'aws/s3'

module MongoDbUtils

  module Tools

    class ToolsException < RuntimeError
      attr :cmd, :output
      def initialize(cmd, output, message)
        super(message)
        @cmd = cmd
        @output = output
      end

    end

    class BaseCmd

      def initialize(cmd_name, host_and_port, db, username = '', password = '')
        @unsafe_options = build_base_options(host_and_port, db, username, password)
        @options_without_credentials = build_base_options(host_and_port, db, username.empty? ? '':'****', password.empty? ? '':'****')
        @cmd_name = cmd_name
      end

      def run
        puts "[#{self.class}] run: #{cmd}"
        output = `#{executable_cmd} 2>&1`
        raise ToolsException.new("#{cmd}", output, "Error in #{cmd_name}:: #{output} cmd #{cmd}") unless $?.to_i == 0
      end

      def cmd
        "#{@cmd_name} #{options_string(@options_without_credentials)}"
      end

      def executable_cmd
        "#{@cmd_name} #{options_string(@unsafe_options)}"
      end

      private
      
      def add_option(option)
        @unsafe_options << option
        @options_without_credentials << option
      end

      def o(key,value)
        Option.new(key,value)
      end

      # options common to all commands
      def build_base_options(host_and_port,db,username='',password='')
        options = []
        options << o('-h', host_and_port)
        options << o('-db', db)
        options << o('-u', username)
        options << o('-p', password)
        options
      end

      # given an array of options build a string of those options unless the option is empty
      def options_string(opts)
        opt_strings = opts.reject{ |o| o.empty? }.map { |o| o.to_s }
        opt_strings.join(' ').strip
      end
    end

    class Dump < BaseCmd
      def initialize(host_and_port,db,output,username = '', password = '')
        super('mongodump', host_and_port, db, username, password)
        add_option(o('-o', output))
      end
    end

    class Restore < BaseCmd
      def initialize(host_and_port,db,source_folder,username = '', password = '')
        super('mongorestore', host_and_port, db, username, password)
        add_option('--drop')
        @source_folder = source_folder
      end

      def cmd
        "#{super} #{@source_folder}"
      end

      def executable_cmd
        "#{super} #{@source_folder}"
      end
    end

    class Import < BaseCmd
      def initialize(host_and_port, db, collection, file, username = '', password = '', opts = {})
        super('mongoimport', host_and_port, db, username, password)
        add_option(o('-c', collection))
        add_option(o('--file', file))
        add_option('--jsonArray') if opts[:json_array]
        add_option('--drop') if opts[:drop]
      end
    end

    class Export < BaseCmd

      def initialize(host_and_port, db, collection, query, output, username = '', password = '', opts = {})
        super('mongoexport', host_and_port, db, username, password)
        add_option(o('-c', collection))
        add_option(o('-o', output))
        add_option(o('--query', "'#{query}'"))
        add_option('--jsonArray') if opts[:json_array]
      end
    end

    class Option
      attr_accessor :key, :value

      def initialize(key,value = nil)
        @key = key
        @value = value
      end

      def empty?
        (@value.nil? || @value.empty?)
      end

      def to_s
        if empty?
          nil
        else
          "#{@key} #{@value}"
        end
      end

      private
      def value_empty?
        @value.nil? || @value.empty?
      end
    end
  end
end
