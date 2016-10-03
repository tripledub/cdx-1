# Patientes test order
class PatientTestOrdersController < ApplicationController
  respond_to :json

  before_filter :find_patient

  before_action :find_encounter, only: [:update]

  def index
    render json: TestOrders::Presenter.index_view(@patient.encounters
      .includes(:institution, :patient, :site, :user)
      .joins('LEFT OUTER JOIN sites as performing_sites ON performing_sites.id=encounters.performing_site_id')
      .order(set_order_from_params).limit(30).offset(params[:page].to_i || 0))
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
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field].to_s
    when 'requestedSiteName'
      "sites.name #{order}"
    when 'batchId'
      "encounters.batch_id #{order}"
    when 'requester'
      "users.first_name #{order}, users.last_name"
    when 'dueDate'
      "encounters.testdue_date #{order}"
    when 'status'
      "encounters.status #{order}"
    when 'performingSite'
      "performing_sites.name #{order}"
    else
      "encounters.start_time #{order}"
    end
  end
end
