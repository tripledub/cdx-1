class PatientTestResultsController < ApplicationController
  respond_to :json

  before_filter :find_patient

  def index
    render json: Presenters::PatientTestResults.patient_view(@patient.test_results.joins(:patient).order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field].to_s == 'name'
    when 'site'
      "patient.name #{order}"
    else
      "patient_results.created_at #{order}"
    end
  end
end
