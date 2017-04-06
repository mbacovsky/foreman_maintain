class Features::SyncPlans < ForemanMaintain::Feature
  metadata do
    label :sync_plans
  end

  def active_sync_plans_count
    feature(:foreman_database).query(
      <<-SQL
        SELECT count(*) AS count FROM katello_sync_plans WHERE enabled ='t'
      SQL
    ).first['count'].to_i
  end

  def ids_by_status(enabled = true)
    enabled = enabled ? 't' : 'f'
    feature(:foreman_database).query(
      <<-SQL
        SELECT id FROM katello_sync_plans WHERE enabled ='#{enabled}'
      SQL
    ).map { |r| r['id'].to_i }
  end

  def disabled_plans_count
    data[:disabled].length
  end

  def make_disable(ids)
    update_records(ids, false)
  end

  def make_enable
    update_records(data[:enabled], true)
  end

  private

  def update_records(ids, enabled)
    updated_record_ids = []
    ids.each do |sp_id|
      result = hammer("sync-plan update --id #{sp_id} --enabled #{enabled}")
      if result.include?('Sync plan updated')
        updated_record_ids << sp_id
      else
        raise result
      end
    end
    data[enabled ? :enabled : :disabled] = updated_record_ids
  ensure
    save_state
  end

  def data
    @data ||= ForemanMaintain.storage(:upgrade).fetch(:sync_plans, {:enabled => [], :disabled => []})
  end

  def save_state
    storage = ForemanMaintain.storage(:upgrade)
    storage[:sync_plans] = data
    storage.save
  end
end
