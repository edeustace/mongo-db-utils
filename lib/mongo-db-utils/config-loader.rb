module MongoDbUtils

  class ConfigLoader
    
    ROOT_FOLDER = "~/.mongo-db-utils"
    CONFIG_LOCATION = "#{ROOT_FOLDER}/config.yml"

    def self.load(load_path = CONFIG_LOCATION)
      full_path = self.expand(load_path)
      puts "loading config from #{full_path}"

      if File.exist?(full_path) && YAML.load(File.open(full_path))
        config = YAML.load(File.open(full_path))
        config.writer = self
        config
      else
        config = Model::Config.new
        config.writer = self
        config.backup_folder = "#{ROOT_FOLDER}/backups"
        self.initialize_files(full_path)
        File.open( full_path, 'w' ) do |out|
          YAML.dump( config, out )
        end
        config
      end
    end

    def self.flush(path = CONFIG_LOCATION)
      path = self.expand(path)
      puts "removing: #{path}"
      FileUtils.rm(path) if File.exist?(path)
      self.initialize_files(path)
    end

    def self.save(config, path = CONFIG_LOCATION)
      self._save(config, self.expand(path))
    end

    private 
    def self._save(config,full_path)
      
      raise "config is nil" if config.nil?

      File.open( full_path, 'w' ) do |out|
        YAML.dump( config, out )
      end
    end

    def self.get_folder_name(path)
      /(.*)\/.*.yml/.match(path)[1]
    end

    def self.initialize_files(path)
      folder = self.get_folder_name(path)
      FileUtils.mkdir_p(folder) unless File.exist?(folder)
      FileUtils.touch(path)
    end

    def self.expand(p)
      File.expand_path("~/#{p}")
    end
  end
end
