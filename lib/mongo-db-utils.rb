require "mongo-db-utils/version"

module MongoDbUtils
    class Runner
      def self.say_hello(name)
        "hello #{name}"
      end
    end

    class Controller
      def self.load_config
      end
    end
end
