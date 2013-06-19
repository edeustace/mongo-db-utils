require 'mongo-db-utils/models/db'
module MongoDbUtils

  module Model
    class Config
      attr_reader :dbs, :buckets
      attr_writer :writer
      attr_accessor :backup_folder

      def initialize
        @dbs = []
        @buckets = []
      end

      def empty?
        @dbs.nil? || @dbs.empty?
      end

      def has_buckets?
        !@buckets.nil? && !@buckets.empty?
      end

      def flush
        @dbs = []
        @writer.flush
      end

      def remove_db(db)
        @dbs = @dbs - [db]
        save
      end

      def add_replica_set(uri, name)
        add_db ReplicaSetDb.new(uri,name)
      end


      def add_db_from_uri(uri)
        add_db Db.new(uri)
      end

      def already_contains(db)
        !@dbs.find{|current| current.uri == db.uri }.nil?
      end

      # because we are serializing the config - the bucket may be nil
      # at this point
      def add_bucket(bucket)
        @buckets = [] if @buckets.nil?
        unless already_contains_bucket?(bucket)
          @buckets << bucket
          save
        end
      end

      def already_contains_bucket?(bucket)
        !@buckets.find{ |b| b.to_s == bucket.to_s}.nil?
      end

      def to_s
        "Config"
      end

      private
      def save
        @writer.save(self) unless @writer.nil?
      end

      def add_db(db)
        @dbs = [] if @dbs.nil?
        unless db.nil? || already_contains(db)
          @dbs << db
          @dbs.sort!
          save
        end
        @dbs.include?(db) && !db.nil?
      end

    end

  end
end
