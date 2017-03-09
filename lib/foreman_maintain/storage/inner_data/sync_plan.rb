module ForemanMaintain
  module Storage
    module InnerData
      module SyncPlan
        MAKE_SYNC_PLANS_DISABLE = 'add'.freeze
        MAKE_SYNC_PLANS_ENABLE = 'remove'.freeze

        class << self
          def ids(data)
            return [] if sync_plans_absent?(data)
            data['sync_plans']['update']['ids'].to_a
          end

          def construct_data(data, new_ids, enabled)
            action_name = sync_plan_action?(enabled)
            data = sync_plans_update_info(data)
            data['sync_plans']['update']['ids'] = build_new_ids(
              data['sync_plans']['update']['ids'], new_ids, action_name
            )
            data
          end

          def sync_plans_absent?(data)
            !data.key?('sync_plans') ||
              (data['sync_plans'] && !data['sync_plans'].key?('update')) ||
              (data['sync_plans'] && data['sync_plans']['update'] &&
               !data['sync_plans']['update'].key?('ids'))
          end

          def build_new_ids(old_ids, new_ids, action_name)
            old_ids ||= []
            case action_name
            when MAKE_SYNC_PLANS_DISABLE
              old_ids.concat(new_ids)
            when MAKE_SYNC_PLANS_ENABLE
              old_ids -= new_ids
            end
            old_ids.uniq!
            old_ids
          end

          def sync_plans_update_info(existing_data)
            existing_data = {} unless existing_data
            existing_data['sync_plans'] ||= {}
            existing_data['sync_plans']['update'] ||= {}
            existing_data
          end

          def sync_plan_action?(enabled)
            return MAKE_SYNC_PLANS_ENABLE if enabled
            MAKE_SYNC_PLANS_DISABLE
          end
        end
      end
    end
  end
end
