class PatientLogsController < ApplicationController
  respond_to :json

  before_filter :find_patient

  expose(:patient_logs, scope: -> { @patient.audit_logs }, model: 'AuditLogs')

  def index
    render json: Presenters::PatientLogs.patient_view(patient_logs.joins(:user).order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient
    @patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'desc' : 'asc'
    params[:field] == 'name' ? "users.first_name #{order}, users.last_name" : "audit_logs.created_at #{order}"
  end
end
