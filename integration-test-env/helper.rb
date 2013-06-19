require 'yaml'
require 'fileutils'
require 'mongo'

class MongoEnvMaker

  attr_reader :pids

  def initialize(root_folder)
    @root_folder = root_folder
    @pids = []
  end


  def spawn(port, rs_name = nil)
    `mkdir -p #{@root_folder}/logs/#{port}`
    out_log = "#{@root_folder}/logs/#{port}/out.log"
    err_log = "#{@root_folder}/logs/#{port}/err.log"
    pid = Process.spawn mongod(port, rs_name), :out=> out_log, :err => err_log
    @pids << pid
  end

  private
  def mongod(port, set_name = nil)
    path = mk_db_dir(port)
    out = "mongod --port #{port} --dbpath #{path}  --smallfiles --oplogSize 128"
    out << " --replSet #{set_name}" unless set_name.nil?
    out
  end

  def mk_db_dir(port)
    path = "#{@root_folder}/dbs/#{port}"
    FileUtils.rm_rf path
    `mkdir -p #{path}`
    path
  end
end