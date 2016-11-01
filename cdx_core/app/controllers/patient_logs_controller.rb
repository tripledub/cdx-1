# Patient logs controller
class PatientLogsController < ApplicationController
  respond_to :json

  before_filter :find_patient

  before_filter :find_patient_log, only: [:show]

  def index
    page = params[:page] || 1
    logs = @patient.audit_logs.includes(:user, :device).order(set_order_from_params).page(page).per(10)
    render json: PatientLogs::Presenter.patient_view(logs, params['order_by'])
  end

  def show
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def find_patient_log
    @patient_log = @patient.audit_logs.find(params[:id])
  end

  def set_order_from_params
    default_order(params['order_by'], table: 'patients_logs_index', field_name: 'audit_logs.created_at')
  end
end
