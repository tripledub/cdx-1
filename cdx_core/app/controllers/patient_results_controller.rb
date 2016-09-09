class PatientResultsController < ApplicationController

  before_filter :find_requested_test, :check_permissions, :check_back_button_mode

  protected

  def find_requested_test
    @requested_test = RequestedTest.find(params[:requested_test_id])
  end

  def check_permissions
    redirect_to(encounter_path(@requested_test.encounter), error: I18n.t('patient_results_controller.cannot_add')) unless has_access?(TestResult, Policy::Actions::QUERY_TEST)
  end

  def check_back_button_mode
    @return_page_mode = params['test_order_page_mode']
  end
end
