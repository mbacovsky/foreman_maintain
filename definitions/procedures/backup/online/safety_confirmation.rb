module Procedures::Backup
  module Online
    class SafetyConfirmation < ForemanMaintain::Procedure
      metadata do
        description 'Data consistency warning'
        tags :backup
      end

      def run
        answer = ask_decision(
          "*** WARNING: The online backup is intended for making a copy of the data\n" \
          '*** for debugging purposes only.' \
          " The backup routine can not ensure 100% consistency while the\n" \
          "*** backup is taking place as there is a chance there may be data mismatch between\n" \
          '*** Mongo and Postgres databases while the services are live.' \
          " If you wish to utilize the online backup\n" \
          '*** for production use you need to ensure that there are' \
          " no modifications occurring during\n" \
          "*** your backup run.\n\nDo you want to proceed?", 'y(yes), q(quit)'
        )
        abort! unless answer == :yes
      end
    end
  end
end
