require 'mongo-db-utils/models/bucket'
require 'mongo-db-utils/models/config'
require 'mongo-db-utils/models/db'

require 'yaml'

module MongoDbUtils

  class ConfigLoader

    ROOT_FOLDER = File.join("~",".mongo-db-utils")
    CONFIG_LOCATION = File.join(ROOT_FOLDER, "config.yml")

    attr_reader :config

    def initialize(config_path)
      @config_path = config_path
      load
    end

    def flush
      path = File.expand_path(@config_path)
      puts "removing: #{path}"
      FileUtils.rm(path) if File.exist?(path)
      initialize_files(path)
    end

    def save(config)
      raise "config is nil" if config.nil?
      File.open( File.expand_path(@config_path), 'w' ) do |out|
        YAML.dump( config, out )
      end
    end

    private

    def load
      full_path = File.expand_path(@config_path)
      puts "loading config from #{full_path}"

      if File.exist?(full_path) && YAML.load(File.open(full_path))
        config = YAML.load(File.open(full_path))
        config.writer = self
        @config = config
      else
        @config = create_fresh_install_config(full_path)
      end
    end

    def create_fresh_install_config(full_path)
        config = Model::Config.new
        config.writer = self
        config.backup_folder = File.join(ROOT_FOLDER, "backups")
        initialize_files(full_path)
        File.open( full_path, 'w' ) do |out|
          YAML.dump( config, out )
        end
        config
    end

    def get_folder_name(path)
      /(.*)\/.*.yml/.match(path)[1]
    end

    def initialize_files(path)
      folder = get_folder_name(path)
      FileUtils.mkdir_p(folder) unless File.exist?(folder)
      FileUtils.touch(path)
    end

  end
end
