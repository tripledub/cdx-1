class PatientTestOrdersController < ApplicationController
  respond_to :json

  before_filter :find_patient

  def index
    render json: Presenters::PatientTestOrders.patient_view(@patient.encounters.order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field].to_s == 'name'
    when 'site'
      "sites.name #{order}"
    when 'orderId'
      "encounters.uuid #{order}"
    when 'requester'
      "users.first_name #{order}, users.last_name"
    when 'dueDate'
      "encounters.testdue_date #{order}"
    when 'status'
      "encounters.status #{order}"
    else
      "encounters.start_time #{order}"
    end
  end
end
