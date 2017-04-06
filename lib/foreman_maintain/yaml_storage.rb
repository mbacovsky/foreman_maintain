module ForemanMaintain
  class YamlStorage
    attr_reader :sub_key, :data
    extend Forwardable
    def_delegators :data, :[], :[]=

    def initialize(sub_key, data = {})
      @sub_key = sub_key
      @data = data
    end

    def save
      self.class.save_sub_key(sub_key, data)
    end

    class << self
      def self.load_file
        if File.exist?(file_path)
          YAML.load_file(storage_file_path)
        else
          {}
        end
      end

      def storage_file_path
        File.expand_path(ForemanMaintain.config.storage_file)
      end

      def storage_register
        @storage_register ||= {}
      end

      def load(sub_key)
        storage_register[sub_key] ||= load_file.fetch(sub_key, {})
      end

      def save_sub_key(sub_key, data)
        new_data = load_file.merge(sub_key => data)
        File.open(storage_file_path, 'w') { |f| f.write new_data.to_yaml }
      end

      def save_all
        storage_register.values.each(&:save)
      end
    end
  end
end
