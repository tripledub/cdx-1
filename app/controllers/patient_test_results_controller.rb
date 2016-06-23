class PatientTestResultsController < ApplicationController
  respond_to :json

  before_filter :find_patient

  expose(:patient_test_results, scope: -> { @patient.test_results }, model: 'TestResult')

  def index
    render json: Presenters::PatientTestResults.patient_view(patient_test_results.order(created_at: :desc).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient
    @patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
  end
end
