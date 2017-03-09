module ForemanMaintain
  class YamlStorage
    def fetch_data
      file_path = storage_file_path
      File.open(file_path, 'a+') unless File.exist?(file_path)
      YAML.load(File.open(file_path)) || {}
    end

    def store_data(data)
      File.open(storage_file_path, 'w') { |f| f.write data.to_yaml }
    end

    def storage_file_path
      File.expand_path(ForemanMaintain.config.storage_file)
    end
  end
end
