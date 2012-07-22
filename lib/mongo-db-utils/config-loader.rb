module MongoDbUtils

  class ConfigLoader

    def self.load( load_path = ".mongo-db-utils/config.yml")
      full_path = self.expand(load_path)
      puts "loading config from #{full_path}"

      if File.exist?(full_path)
        config = YAML.load(File.open(full_path))
        
        if config == false
          config = Model::Config.new
          config.writer = self
          config.save
          config
        else
          config.writer = self
          config
        end
      else
        self.initialize_files(full_path)
        config = Model::Config.new
        config.writer = self
        File.open( full_path, 'w' ) do |out|
          YAML.dump( config, out )
        end
        config
      end
    end

    def self.flush( path = ".mongo-db-utils/config.yml" )
      path = self.expand(path)
      puts "removing: #{path}"
      FileUtils.rm(path) if File.exist?(path)
      puts "flush::success? #{!File.exist?(path)}"
      self.initialize_files(path)
    end

    def self.save(config, path = ".mongo-db-utils/config.yml")
      self._save(config, self.expand(path))
    end

    private 
    def self._save(config,full_path)
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
