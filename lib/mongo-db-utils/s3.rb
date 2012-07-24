require 'aws/s3'

module MongoDbUtils

  class S3

    def self.put_file(file, name, bucket_name, access_key_id, secret_access_key)
      puts "putting file to Amazon S3"
      AWS::S3::Base.establish_connection!(
        :access_key_id     => access_key_id,
        :secret_access_key => secret_access_key
      )

      begin
        AWS::S3::Bucket.find(bucket_name)
      rescue AWS::S3::NoSuchBucket
        AWS::S3::Bucket.create(bucket_name)
      rescue AWS::S3::AllAccessDisabled
        puts "Error:: You cannot access this bucket: #{bucket_name}"
        return
      end
      AWS::S3::S3Object.store(name, open(file), bucket_name)
    end
  end
end
