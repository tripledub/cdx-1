# Patient logs controller
class PatientLogsController < ApplicationController
  respond_to :json

  before_filter :find_patient

  before_filter :find_patient_log, only: [:show]

  def index
    page = params[:page] || 1
    logs = @patient.audit_logs.includes(:user, :device).order(set_order_from_params).page(page).per(10)
    render json: PatientLogs::Presenter.patient_view(logs)
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
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field]
    when 'user'
      "users.first_name #{order}, users.last_name"
    when 'device'
      "devices.name #{order}, devices.serial_number"
    when 'title'
      "audit_logs.title #{order}"
    else
      "audit_logs.created_at #{order}"
    end
  end
end
