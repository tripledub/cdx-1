class AuditUpdatesController < ApplicationController
  respond_to :json, only: [:index]

  before_filter :find_patient_and_log

  def index
    render json: AuditUpdates::Presenter.patient_view(@audit_log.audit_updates.order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient_and_log
    patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
    @audit_log = patient.audit_logs.where(id: params[:patient_log_id]).first
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'desc' : 'asc'
    params[:field] == 'name' ? "audit_updates.fied_name #{order}" : "audit_updates.created_at #{order}"
  end
end
