require 'singleton'
module ForemanMaintain
  module Storage
    class Upgrade < YamlStorage
      include Singleton

      def retrive_sync_plan_ids
        InnerData::SyncPlan.ids(fetch_data)
      end

      def store_sync_plans(ids, enabled)
        sync_plan_obj = InnerData::SyncPlan.construct_data(
          fetch_data, ids, enabled
        )
        store_data(sync_plan_obj)
      end
    end
  end
end
