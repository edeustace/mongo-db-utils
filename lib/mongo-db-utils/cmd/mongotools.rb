module MongoDbUtils
  module Commands

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

    class MongoTools

      def self.dump(host,port,db,output,username = "", password = "")

        options = []
        options << Option.new("-h", "#{host}:#{port}")
        options << Option.new("-db", db)
        options << Option.new("-o", output)
        options << Option.new("-u", username)
        options << Option.new("-p", password)

        cmd = "mongodump "

        options.each do |o|
          cmd << "#{o.key} #{o.value} " unless o.empty?
        end
        puts "cmd:"
        puts cmd
        `#{cmd}`

      end
    end
  end
end
