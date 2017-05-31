module Checks
  class CandlepinDBRunning < ForemanMaintain::Check
    metadata do
      label :candlepin_db_running
      for_feature :candlepin_database
      description 'check for running Candlepin database'
      tags :database
    end

    def run
      ping = feature(:candlepin_database).ping
      assert(ping == "ping \n------\n    1\n(1 row)",
             "Can't connect to the Candlepin database (#{ping})")
    end
  end
end