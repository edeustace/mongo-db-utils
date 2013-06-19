module MongoDbUtils
  module Model

   class Bucket
    attr_accessor :name, :access_key, :secret_key

    def to_s
      "#{name} | #{access_key} | #{secret_key}"
    end

    def <=> (other)
      self.name <=> other.name
    end
  end

end
end