require 'mongo-db-utils/config-loader'

describe MongoDbUtils do

    it "should create a config if one doesn't exist" do
    
      tmp_file = ".tmp_path/config.yml"

      FileUtils.rm_rf(".tmp_path")

      File.exist?(tmp_file).should eql(false)

      config = MongoDbUtils::ConfigLoader.load(".tmp_path/config.yml")
      
      File.exist?(tmp_file).should eql(true)
      
      FileUtils.rm_rf(".tmp_path")

    end

end
