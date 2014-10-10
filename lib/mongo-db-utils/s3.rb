require 'aws/s3'

module MongoDbUtils

  class S3

    def self.put_file(file, name, bucket_name, access_key_id, secret_access_key)
      puts "putting file to Amazon S3"

      self.s3connect(access_key_id, secret_access_key)

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


    def self.get_file(filename, key, bucket_name, access_key_id, secret_access_key)
      puts "getting file from Amazon S3"

      self.s3connect(access_key_id, secret_access_key)

      File.open(filename, 'wb') do |file|
        AWS::S3::S3Object.stream(key, bucket_name) do |chunk|
          file.write chunk
        end
        file.close
      end
    end


    def self.list_bucket(bucket_name, access_key_id, secret_access_key)
      puts "getting list of bucket keys from Amazon S3"

      self.s3connect(access_key_id, secret_access_key)

      begin
        AWS::S3::Bucket.find(bucket_name).objects.collect(&:key)
      rescue AWS::S3::NoSuchBucket
        puts "Error:: Bucket does not exist: #{bucket_name}"
        return nil
      rescue AWS::S3::AllAccessDisabled
        puts "Error:: You cannot access this bucket: #{bucket_name}"
        return nil
      end
    end

    private

    def self.s3connect(access_key_id, secret_access_key)
      AWS::S3::Base.establish_connection!(
        :access_key_id => access_key_id,
        :secret_access_key => secret_access_key
      )
    end

  end
end
