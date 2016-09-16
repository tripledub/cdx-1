class PatientResultsController < ApplicationController

  before_filter :find_test_batch, :check_permissions, :check_back_button_mode

  def update_samples
    PatientResults::Persistence.collect_sample_ids(@test_batch, params[:samples])
    render json: 'ok', status: :ok
  end

  protected

  def find_test_batch
    @test_batch = @navigation_context.institution.test_batches.find(params[:test_batch_id])
  end

  def check_permissions
    redirect_to(encounter_path(@test_batch.encounter), error: I18n.t('patient_results_controller.cannot_add')) unless has_access?(TestResult, Policy::Actions::QUERY_TEST)
  end

  def check_back_button_mode
    @return_page_mode = params['test_order_page_mode']
  end
end
