require 'aws/s3'

module MongoDbUtils

    class S3

      def self.put_file(file, bucket_name, access_key_id, secret_access_key)
        puts "putting file to Amazon S3"
        AWS::S3::Base.establish_connection!(
          :access_key_id     => access_key_id,
          :secret_access_key => secret_access_key
        )

        AWS::S3::Service.buckets.create(bucket_name) if AWS::S3::Service.buckets.find(bucket_name).nil?
        AWS::S3::S3Object.store(file, open(file), bucket_name)
      end
    end
end
