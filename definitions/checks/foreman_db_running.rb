module Checks
  class ForemanDBRunning < ForemanMaintain::Check
    metadata do
      label :foreman_db_running
      for_feature :foreman_database
      description 'check for running Foreman database'
      tags :database
    end

    def run
      ping = feature(:foreman_database).ping
      assert(ping == "ping \n------\n    1\n(1 row)",
                   "Can't connect to the Foreman database (#{ping})")
    end
  end
end