module Procedures::Restore
  class EnsureMongoEngineMatches < ForemanMaintain::Procedure
    metadata do
      description 'Ensure restored MongoDB storage engine matches the current DB'
      for_feature :mongo
    end

    def run
      if feature(:mongo).local? && engine_mismatch?
        with_spinner('') do |spinner|
          feature(:service).handle_services(spinner, 'stop', :only => feature(:mongo).services)
          spinner.update('Clean MongoDB data')
          data_path = Dir[feature(:mongo).data_dir + '/*']
          FileUtils.rm_rf(data_path)
          feature(:service).handle_services(spinner, 'start', :only => feature(:mongo).services)
        end
      end
    end

    private

    def engine_mismatch?
      tiger_file = File.join(feature(:mongo).data_dir, 'WiredTiger.wt')
      config_file = feature(:mongo).core.server_config_files.first
      File.exist?(tiger_file) && File.open(config_file).grep(/^storage.engine:\s*mmapv1/).any?
    end
  end
end
