require 'aws/s3'

module MongoDbUtils

  module Tools

    class ToolsException < RuntimeError
      attr :cmd, :output
      def initialize(cmd, output)
        @cmd = cmd
        @output =output
      end
    end

    class BaseCmd
      private
      def self.o(key,value)
        Option.new(key,value)
      end

      # options common to all commands
      def self.build_base_options(host_and_port,db,username="",password="")
        options = []
        options << o("-h", host_and_port)
        options << o("-db", db)
        options << o("-u", username)
        options << o("-p", password)
        options
      end

      # given an array of options build a string of those options unless the option is empty
      def self.options_string(opts)
        out = ""
        opts.each do |o|
          out << "#{o.key} #{o.value} " unless o.empty?
        end
        out.strip
      end
    end

    class Dump < BaseCmd
      # create the cmd string that will be executed by the system
      def self.cmd(host_and_port,db,output,username = "", password = "")
        options = build_base_options(host_and_port,db,username,password)
        options << o("-o", output)
        "mongodump #{options_string(options)}"
      end

      # run the command
      def self.run(host_and_port,db,output,username="", password ="")
        cmd_string = self.cmd(host_and_port,db,output,username,password)
        puts "[Dump] run: #{cmd_string}"
        output = `#{cmd_string}`
        raise ToolsException.new("#{cmd_string}", output) unless $?.to_i == 0
      end
    end

    class Restore < BaseCmd
      def self.cmd(host_and_port,db,source_folder,username = "", password = "")
        options = build_base_options(host_and_port,db,username,password)
        params = options_string(options) << " --drop #{source_folder}"
        "mongorestore #{params}"
      end

      def self.run(host_and_port,db,source_folder,username="", password ="")
        cmd_string = self.cmd(host_and_port,db,source_folder,username,password)
        puts "[Restore] run: #{cmd_string}"
        output = `#{cmd_string}`
        raise ToolsException.new("#{cmd_string}", output) unless $?.to_i == 0
      end
    end


    class Option
      attr_accessor :key, :value

      def initialize(key,value)
        @key = key
        @value = value
      end

      def empty?
        @value.nil? || @value.empty?
      end
    end
  end
end
