module MongoDbUtils
  class Cmd

    def self.backup(db)
      t = Time.new
      timestamp = t.strftime("%Y.%m.%d__%H.%M")
      out_path = "~/.mongo-db-utils/backups/#{db.host}_#{db.port}/#{db.name}/#{timestamp}"
      full_path = File.expand_path(out_path)
      FileUtils.mkdir_p(full_path)
      `mongodump -h #{db.host}:#{db.port} -db #{db.name} -o #{full_path} -u #{db.username} -p #{db.password}`
      `tar cvf #{full_path}/#{db.name}.tar.gz #{full_path}/#{db.name}`
      `rm -fr #{full_path}/#{db.name}`
    end

    def self.list_dbs(servers)
      result = []
      servers.each do |server|
        server_dbs = Hash.new
        server_dbs[:server] = server
        uri = self.make_uri(server)
        puts "uri: #{uri}"
        connection = Mongo::Connection.from_uri( uri )
        server_dbs[:names] = connection.database_names
        result << server_dbs
        connection.close
      end
      result
    end

  end
end

