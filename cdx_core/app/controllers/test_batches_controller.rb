class TestBatchesController < ApplicationController

  before_filter :find_encounter, :check_permissions

  def set_as_paid
    @encounter.test_batch.update_attribute(:payment_done, true)
    redirect_to encounter_path(@encounter), message: I18n.t('test_batches.set_as_paid.payment_done')
  end

  protected

  def find_encounter
    @encounter = @navigation_context.institution.encounters.find(params['encounter_id'])
  end

  def check_permissions
    redirect_to(encounter_path(@encounter), error: I18n.t('test_batches.set_as_paid.not_allowed')) unless has_access?(@encounter, Policy::Actions::UPDATE_ENCOUNTER)
  end
end
