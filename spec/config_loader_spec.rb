require 'mongo-db-utils/config-loader'

describe MongoDbUtils do

    it "should create a config if one doesn't exist" do

      tmp_file = ".tmp_path/config.yml"

      FileUtils.rm_rf(".tmp_path")

      File.exist?(tmp_file).should eql(false)

      config = MongoDbUtils::ConfigLoader.new(".tmp_path/config.yml").config

      File.exist?(tmp_file).should eql(true)

      FileUtils.rm_rf(".tmp_path")

    end

    it "should write a config correctly" do
      path = ".tmp_path/config2.yml"
      config = MongoDbUtils::ConfigLoader.new(path).config
      config.add_db("mongodb://localhost:27017/db")
      loaded_config = YAML.load(File.open(path))
      loaded_config.dbs[0].uri.should == config.dbs[0].uri
    end


end
