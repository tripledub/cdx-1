class PatientTestOrdersController < ApplicationController
  respond_to :json

  before_filter :find_patient

  expose(:patient_test_orders, scope: -> { @patient.encounters }, model: 'Encounters')

  def index
    render json: Presenters::PatientTestOrders.patient_view(patient_test_orders.order(set_order_from_params).limit(30).offset(params[:page] || 0))
  end

  protected

  def find_patient
    @patient = Patient.where(institution: @navigation_context.institution, id: params[:patient_id]).first
  end

  def set_order_from_params
    order = params[:order] == 'true' ? 'desc' : 'asc'
    field_name = case params[:field].to_s == 'name'
    when 'site'
      'sites.name'
    when 'orderId'
      'encounters.uuid'
    when 'requester'
      'users.first_name, users.last_name'
    when 'dueDate'
      'encounters.testdue_date'
    else 'encounters.start_time'
    end

    "#{field_name} #{order}"
  end
end
