class Features::CandlepinDatabase < ForemanMaintain::Feature
  CANDLEPIN_DB_CONFIG = '/etc/candlepin/candlepin.conf'

  metadata do
    label :candlepin_database

    confine do
      File.exist?(CANDLEPIN_DB_CONFIG)
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
    raw_config = File.read(CANDLEPIN_DB_CONFIG)
    full_config = Hash[raw_config.scan(/(^[^#\n][^=]*)=(.*)/)]
    uri = /:\/\/(([^\/:]*):?([^\/]*))\/(.*)/.match(full_config['org.quartz.dataSource.myDS.URL'])
    @configuration = {
        'username' => full_config['org.quartz.dataSource.myDS.user'],
        'password' => full_config['org.quartz.dataSource.myDS.password'],
        'database' => uri[4],
        'host' => uri[2],
        'port' => uri[3] || '5432'
    }
  end
end
