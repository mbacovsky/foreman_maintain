class Features::ForemanDatabase < ForemanMaintain::Feature
  FOREMAN_DB_CONFIG = '/etc/foreman/database.yml'

  metadata do
    label :foreman_database

    confine do
      File.exist?(FOREMAN_DB_CONFIG)
    end
  end

  def configuration
    @configuration || load_configuration
  end

  def query(sql, config=configuration)
    parse_csv(query_csv(sql, config))
  end

  def query_csv(sql, config=configuration)
    psql(%{COPY (#{sql}) TO STDOUT WITH CSV HEADER}, config)
  end

  def psql(query, config=configuration)
    execute("PGPASSWORD='#{config[%{password}]}' psql -d #{config['database']} -h #{config['host'] || 'localhost'} -p #{config['port'] || '5432'} -U #{config['username']}", :stdin => query)
  end

  def ping(config=configuration)
    psql("SELECT 1 as ping", config)
  end

  private

  def load_configuration
    config = YAML.load(File.read(FOREMAN_DB_CONFIG))
    @configuration = config['production']
  end
end
