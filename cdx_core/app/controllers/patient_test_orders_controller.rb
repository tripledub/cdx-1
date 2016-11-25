# Patientes test order
class PatientTestOrdersController < ApplicationController
  respond_to :json

  before_filter :find_patient

  before_action :find_encounter, only: [:update]

  def index
    page = params[:page] || 1
    render json: TestOrders::Presenter.patient_view(
      @patient.encounters.joins(:institution, :patient, :site, :user)
        .joins('LEFT OUTER JOIN sites as performing_sites ON performing_sites.id=encounters.performing_site_id')
        .order(set_order_from_params).page(page).per(10),
      params['order_by']
    )
  end

  def update
    message, status = TestOrders::Status.update_and_comment(@encounter, encounter_params)
    render json: { result: message }, status: status
  end

  protected

  def find_patient
    @patient = @navigation_context.institution.patients.find(params[:patient_id])
  end

  def find_encounter
    @encounter = @patient.encounters.find(params[:id])
  end

  def encounter_params
    params.require(:encounter).permit(:status, :comment, :feedback_message_id)
  end

  def set_order_from_params
    default_order(params['order_by'], table: 'patients_test_orders_index', field_name: 'encounters.start_time')
  end
end
