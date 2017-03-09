class Procedures::UpgradeSyncPlansDisable < ForemanMaintain::Procedure
  metadata do
    for_feature :sync_plans
    description 'enable/disable sync plans before/after upgrade'
  end

  attr_reader :rollback

  def initialize(options = {})
    @rollback = options[:rollback]
  end

  def run
    if rollback
      enabled_sync_plans
    else
      disable_all_enabled_sync_plans
    end
  end

  private

  def disable_all_enabled_sync_plans
    with_spinner('disabling all sync plans') do |spinner|
      ids = feature(:sync_plans).ids_by_status(true)
      feature(:sync_plans).make_disable(ids)
      spinner.update "Total #{ids.length} sync plans are now disabled."
    end
  end

  def enabled_sync_plans
    feature(:sync_plans).make_enable
  end
end
