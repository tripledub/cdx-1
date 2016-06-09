class AlertsController < ApplicationController
  include AlertsHelper

  respond_to :html, :json

  #could not name it 'alert' as rails gave a warning as this is a reserved method.
  expose(:alert_info, model: :alert, attributes: :alert_params)

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  def new
    new_alert_request_variables
    alert_info.sms_limit=100
    alert_info.email_limit=100
    alert_info.institution_id = @navigation_context.institution.id
    alert_info.utilization_efficiency_number=1
    alert_info.alert_recipients.build
  end

  def index
    @page_size = (params["page_size"] || 10).to_i
    @page = (params["page"] || 1).to_i
    offset = (@page - 1) * @page_size

    @alerts = current_user.alerts
    @total = @alerts.count
    @alerts = @alerts.limit(@page_size).offset(offset)

    respond_with @alerts
  end

  def edit
    new_alert_request_variables

    @alert_sites=[]
    alert_info.sites.each do |site|
      @alert_sites.push(site.id)
    end
    @alert_sites = @alert_sites.join(",")

    @alert_devices=[]
    alert_info.devices.each do |device|
      @alert_devices.push(device.id)
    end
    @alert_devices = @alert_devices.join(",")

    @alert_roles=[]
    alert_info.alert_recipients.each do |recipient|
      if AlertRecipient.recipient_types[recipient.recipient_type] == AlertRecipient.recipient_types["role"]
        @alert_roles.push(recipient.role.id)
      end
    end
    @alert_roles = @alert_roles.join(",")

    @alert_internal_users=[]
    alert_info.alert_recipients.each do |recipient|
      if AlertRecipient.recipient_types[recipient.recipient_type] == AlertRecipient.recipient_types["internal_user"]
        @alert_internal_users.push(recipient.user.id)
      end
    end
    @alert_internal_users = @alert_internal_users.join(",")

    @alert_external_users=[]
    alert_info.alert_recipients.each do |recipient|
      if AlertRecipient.recipient_types[recipient.recipient_type] == AlertRecipient.recipient_types["external_user"]
        @alert_external_users.push(recipient)
      end
    end

    @alert_conditions=[]
    alert_info.conditions.each do |condition|
      @alert_conditions.push(condition.id)
    end
    @alert_conditions = @alert_conditions.join(",")

    @alert_condition_results=[]
    alert_info.alert_condition_results.each do |condition_result|
      @alert_condition_results.push(condition_result.result)
    end
    @alert_condition_results = @alert_condition_results.join(",")

    @alert_number_incidents = current_user.alert_histories.where("alert_id=? and for_aggregation_calculation=?", alert_info.id, false).count
    @alert_last_incident = display_latest_alert_date(alert_info)

    @alert_created_at  = alert_info.created_at.to_formatted_s(:long)
    respond_with alert_info, location: alert_path
  end

  def create
    percolator = Cdx::Alert::Conditions::Percolator.new(params, alert_info)

    if percolator.create(current_user)
      render json: alert_info
    else
      render json: percolator.error_text, status: :unprocessable_entity
    end
  end

  def update
    percolator = Cdx::Alert::Conditions::Percolator.new(params, alert_info)

    if percolator.update
      render json: alert_info
    else
      render json: percolator.error_text, status: :unprocessable_entity
    end
  end

  def destroy
    if alert_info.destroy
      render json: alert_info
    else
      render json: alert_info.errors, status: :unprocessable_entity
    end
  end

  private

  def alert_params
    params.require(:alert).permit(:name, :description, :devices_info, :users_info, :enabled, :sites_info, :error_code,
                                  :message, :sms_message, :sample_id, :site_id, :category_type, :notify_patients, :aggregation_type,
                                  :anomalie_type, :aggregation_frequency, :channel_type, :sms_limit, :email_limit,
                                  :aggregation_threshold, :roles, :external_users, :conditions_info, :condition_results_info,
                                  :condition_result_statuses_info, :test_result_min_threshold, :test_result_max_threshold,
                                  :utilization_efficiency_number, :use_aggregation_percentage, :institution_id,
                                  alert_recipients_attributes: [:user, :user_id, :email, :role, :role_id, :id] )
  end

  def new_alert_request_variables
    @sites   = check_access(Site.within(@navigation_context.entity), READ_SITE)
    @roles   = check_access(Role, READ_ROLE)
    @devices = check_access(Device.within(@navigation_context.entity), READ_DEVICE)

    @conditions        = Condition.all
    @condition_results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options
    #Note: in case you need to specify the exact N/A:  @condition_result_statuses = Cdx::Fields.test.core_fields.find { |field| field.name == 'status' }.options

    #find all users in all roles
    user_ids = @roles.map { |user| user.id }
    user_ids = user_ids.uniq
    @users = User.where(id: user_ids)
  end
end
