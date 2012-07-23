require 'aws/s3'

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


      def self.restore(host,port,db,source_folder,username = "", password = "")

        options = []
        options << Option.new("-h", "#{host}:#{port}")
        options << Option.new("-db", db)
        options << Option.new("-u", username)
        options << Option.new("-p", password)

        cmd = "mongorestore "

        options.each do |o|
          cmd << "#{o.key} #{o.value} " unless o.empty?
        end
        cmd << "#{source_folder}"
        puts "cmd:"
        puts cmd
        `#{cmd}`

      end

    end

    class S3

      def self.put_file(file, bucket_name, access_key_id, secret_access_key)
        AWS::S3::Base.establish_connection!(
          :access_key_id     => access_key_id,
          :secret_access_key => secret_access_key
        )

        Service.buckets.create(bucket_name) if Service.buckets.find(bucket_name).nil?
        S3Object.store(file, open(file), bucket_name)
      end
    end
  end
end
