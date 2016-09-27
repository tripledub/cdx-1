class PatientResultsController < ApplicationController

  before_filter :find_encounter, :check_permissions, :check_back_button_mode

  def update_samples
    if PatientResults::Persistence.collect_sample_ids(@encounter, params[:samples])
      message = I18n.t('patient_results.update_samples.samples_updated')
    else
      message = I18n.t('patient_results.update_samples.updated_fail')
    end

    redirect_to encounter_path(@encounter), message: message
  end

  def update
    message, status = PatientResults::Persistence.update_status(@encounter.patient_results.find(params[:id]), patient_results_params, current_user)
    render json: { result: message }, status: status
  end

  protected

  def find_encounter
    @encounter = @navigation_context.institution.encounters.find(params[:encounter_id])
  end

  def patient_results_params
    params.require(:patient_result).permit(:result_status, :comment, :feedback_message_id)
  end

  def check_permissions
    redirect_to(encounter_path(@encounter), error: I18n.t('patient_results_controller.cannot_add')) unless has_access?(TestResult, Policy::Actions::QUERY_TEST)
  end

  def check_back_button_mode
    @return_page_mode = params['test_order_page_mode']
  end
end
