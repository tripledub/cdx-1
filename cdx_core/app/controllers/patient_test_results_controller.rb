# Patient test results controller
class PatientTestResultsController < ApplicationController
  respond_to :json

  before_action :find_patient

  def index
    page = params[:page] || 1
    render json: PatientTestResults::Presenter.patient_view(
      PatientResult.find_all_results_for_patient(@patient.id).order(set_order_from_params).page(page).per(10),
      params['order_by']
    )
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def set_order_from_params
    default_order(params['order_by'], table: 'patients_test_results_index', field_name: 'patient_results.created_at')
  end
end
