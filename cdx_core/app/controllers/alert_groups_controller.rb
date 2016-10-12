class AlertGroupsController < ApplicationController

  respond_to :html, :json

  #could not name it 'alert' as rails gave a warning as this is a reserved method.
  expose(:alert_info, model: :alert, attributes: :alert_params)

  def new
    return unless authorize_resource(alert_info, CREATE_ALERT)

    @can_update = true
    new_alert_request_variables
    alert_info.sms_limit=100
    alert_info.email_limit=100

    alert_info.site_id = @navigation_context.site.id if @navigation_context.site != nil
    alert_info.institution_id = @navigation_context.institution.id
    alert_info.utilization_efficiency_number=1
    alert_info.alert_recipients.build
  end

  def index
    order_by, offset = perform_pagination('alerts.name')
    @can_create = has_access?(Alert, CREATE_ALERT)
    @alerts = check_access(Alert, READ_ALERT)
    @alerts = @alerts.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @total = @alerts.count
    @alerts = @alerts.order(order_by).limit(@page_size).offset(offset)
    respond_with @alerts
  end

  def edit
    return unless authorize_resource(alert_info, READ_ALERT)
    @can_update = has_access?(@navigation_context.institution, UPDATE_ALERT)
    @can_delete = has_access?(@navigation_context.institution, DELETE_ALERT)

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
    @alert_last_incident = AlertGroups::Presenter.display_latest_alert_date(alert_info)

    @alert_created_at = alert_info.created_at.to_formatted_s(:long)
    respond_with alert_info, location: alert_path
  end

  def create
    return unless authorize_resource(alert_info, CREATE_ALERT)

    external_users_ok = true
    internal_users_ok = true
    condition_result_ok = true
    error_text=Hash.new
    alert_info.user = current_user
    alert_info.time_last_aggregation_checked = Time.now
    alert_info.site = Site.find(alert_info.site_id) if alert_info.site_id != nil

    alert_saved_ok = alert_info.save
    if alert_saved_ok==false
      error_text = alert_info.errors.messages
    else
      alert_info.query="{}"
      edit = false
      internal_users_ok,external_users_ok,error_text = set_channel_info(params, alert_info, internal_users_ok, external_users_ok, error_text, edit)
      condition_result_ok, error_text = set_category(params, alert_info, error_text, condition_result_ok, edit)
      set_sample_id(params, alert_info)
      set_sites_devices_institutions(params, alert_info, edit)
      only_allow_specimen_test_type(alert_info)
      alert_query_updated_ok = alert_info.update(query: alert_info.query)
    end

    if alert_saved_ok && alert_query_updated_ok && external_users_ok && internal_users_ok && condition_result_ok
      render json: alert_info
    else
      render json: error_text, status: :unprocessable_entity
    end
  end

  def update
    return unless authorize_resource(alert_info, UPDATE_ALERT)

    external_users_ok = true
    internal_users_ok = true
    condition_result_ok = true
    error_text=Hash.new

    alert_saved_ok = alert_info.save
    if alert_saved_ok==false
      error_text = alert_info.errors.messages
    else
      #note: the update in the alert model calls create
      if alert_info.enabled == false
        alert_info.delete_percolator
      end

      alert_info.query="{}"
      edit = true
      internal_users_ok,external_users_ok,error_text = set_channel_info(params, alert_info, internal_users_ok, external_users_ok, error_text, edit)

      condition_result_ok,error_text = set_category(params, alert_info, error_text, condition_result_ok, edit)
      set_sample_id(params, alert_info)
      set_sites_devices_institutions(params, alert_info, edit)
      alert_query_updated_ok = alert_info.update(query: alert_info.query)
    end

    if alert_saved_ok && alert_query_updated_ok && external_users_ok && internal_users_ok && condition_result_ok
      render json: alert_info
    else
      render json: error_text, status: :unprocessable_entity
    end
  end

  def destroy
    return unless authorize_resource(alert_info, DELETE_ALERT)

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
                                  :utilization_efficiency_number, :use_aggregation_percentage, :institution_id,:site_id,
                                  alert_recipients_attributes: [:user, :user_id, :email, :role, :role_id, :id] )
  end

  def new_alert_request_variables
    @sites = check_access(Site.within(@navigation_context.entity), READ_SITE)
    @roles = check_access(Role, READ_ROLE)
    @devices = check_access(Device.within(@navigation_context.entity), READ_DEVICE)

    @conditions = Condition.all
    @condition_results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options
    #Note: in case you need to specify the exact N/A:  @condition_result_statuses = Cdx::Fields.test.core_fields.find { |field| field.name == 'status' }.options

    #find all users in all roles
    user_ids = @roles.map { |user| user.id }
    user_ids = user_ids.uniq
    @users = User.where(id: user_ids)
  end

  def append_query(alert, query)
    if  alert.query != "{}"
      alert.query.merge (query)
    else
      query
    end
  end

  def set_sample_id(params, alert_info)
    if (params[:alert][:sample_id]) && (params[:alert][:sample_id].length > 0)
      alert_info.query=append_query(alert_info, {"sample.id"=>params[:alert][:sample_id]})
    end
  end

  def only_allow_specimen_test_type(alert_info)
    alert_info.query=alert_info.query.merge ({"test.type"=>"specimen"})
  end

  def set_sites_devices_institutions(params, alert_info, is_edit)
    if is_edit==true
      alert_info.devices.destroy_all
      alert_info.sites.destroy_all
    end

    #add the institution to the query
    inst = Institution.find(alert_info.institution_id)
    alert_info.query=alert_info.query.merge ({"institution.uuid"=>inst.uuid})

    if params[:alert][:sites_info]
      sites = params[:alert][:sites_info].split(',')
      query_sites=[]
      sites.each do |siteid|
        site = Site.find_by_id(siteid)
        alert_info.sites << site
        query_sites << site.uuid
      end

      alert_info.query=alert_info.query.merge ({"site.uuid"=>query_sites})
    end

    #TODO you have the device uuid, you don’t even need the site uuid
    if params[:alert][:devices_info]
      devices = params[:alert][:devices_info].split(',')
      query_devices=[]
      devices.each do |deviceid|
        device = Device.find_by_id(deviceid)
        alert_info.devices << device
        query_devices << device.uuid
      end
      alert_info.query=alert_info.query.merge ({"device.uuid"=>query_devices})
    end
    #Note: alert_info.create_percolator is called from the model
  end


  def set_category(params, alert_info, error_text, condition_result_ok, is_edit)
    if is_edit==true
      alert_info.conditions.destroy_all
    end

    if alert_info.category_type == "anomalies"
      if alert_info.anomalie_type == "missing_sample_id"
        alert_info.query = {"sample.id"=>"null"}
      end
    elsif alert_info.category_type == "device_errors"
      if alert_info.error_code && (alert_info.error_code.include? '-')
        minmax=alert_info.error_code.split('-')
        alert_info.query =    {"test.error_code.min" => minmax[0], "test.error_code.max"=>minmax[1]}
        #elsif alert_info.error_code.include? '*'
        #   alert_info.query =    {"test.error_code.wildcard" => "*7"}
      else
        alert_info.query = {"test.error_code"=>alert_info.error_code }
      end
    elsif alert_info.category_type == "test_results"
      #this will generate a query like: core_fields: {"assays" =>["condition" => "mtb", "result" => :positive]}
      if params[:alert][:conditions_info]
        conditions = params[:alert][:conditions_info].split(',')
        query_conditions=[]
        conditions.each do |conditionid|
          condition = Condition.find_by_id(conditionid)
          alert_info.conditions << condition
          query_conditions << condition.name
        end
      end

      if params[:alert][:condition_results_info]
        condition_results = params[:alert][:condition_results_info].split(',')
        query_condition_results=[]
        condition_results.each do |condition_result_name|
          alert_condition_result = AlertConditionResult.new
          alert_condition_result.result = condition_result_name
          alert_condition_result.alert=alert_info
          if alert_condition_result.save == false
            condition_result_ok = false
            error_text = error_text.merge alert_condition_result.errors.messages
          end
          query_condition_results << condition_result_name
        end
      end
      alert_info.query= {"test.assays.condition" => query_conditions,"test.assays.result" => query_condition_results}
      #TEST  alert_info.query =    {"assays.quantitative_result.min" => "8"}
      #TEST  alert_info.query =    {"test.assays.condition" => query_conditions, "test.assays.quantitative_result.min" => "8"}

    elsif alert_info.category_type == "utilization_efficiency"
      alert_info.aggregation_type = Alert.aggregation_types.key(1)  #for utilization, it is always an aggregation
      alert_info.utilization_efficiency_last_checked = Time.now
      #Note: the sampleid must be set for this category -in a validation
    end
    return condition_result_ok,error_text
  end

  def set_channel_info(params, alert_info, internal_users_ok, external_users_ok, error_text, is_edit)
    #destroy all recipients before adding them in again on an update

    if (is_edit==true)
      AlertRecipient.destroy_all(alert_id: alert_info.id)
    end

    if params[:alert][:roles]
      roles = params[:alert][:roles].split(',')
      roles.each do |role_id|
        role = Role.find_by_id(role_id)
        alert_recipient = AlertRecipient.new
        alert_recipient.recipient_type = AlertRecipient.recipient_types["role"]
        alert_recipient.role = role
        alert_recipient.alert=alert_info

        if alert_recipient.save == false
          internal_users_ok = false
          error_text = error_text.merge alert_recipient.errors.messages
        end
      end
    end

    #save internal users
    if params[:alert][:users_info]
      internal_users = params[:alert][:users_info].split(',')
      internal_users.each do |user_id|
        user = User.find_by_id(user_id)
        alert_recipient = AlertRecipient.new
        alert_recipient.recipient_type = AlertRecipient.recipient_types["internal_user"]
        alert_recipient.user = user
        alert_recipient.alert=alert_info
        if alert_recipient.save == false
          internal_users_ok = false
          error_text = error_text.merge alert_recipient.errors.messages
        end
      end
    end

    #save external users
    if params[:alert][:external_users]
      external_users = params[:alert][:external_users]

      # using key/pair as value returned in this format  :
      #  {"0"=>{"id"=>"0", "firstName"=>"a", "lastName"=>"b", "email"=>"c", "telephone"=>"d"}, "1"=>{"id"=>"1", "firstName"=>"aa", "lastName"=>"bb", "email"=>"cc", "telephone"=>"dd"}}
      external_users.each do |key, external_user_value|
        alert_recipient = AlertRecipient.new
        alert_recipient.recipient_type = AlertRecipient.recipient_types["external_user"]
        alert_recipient.email = external_user_value["email"]
        alert_recipient.telephone = external_user_value["telephone"]
        alert_recipient.first_name = external_user_value["first_name"]
        alert_recipient.last_name = external_user_value["last_name"]
        alert_recipient.alert=alert_info
        if alert_recipient.save == false
          external_users_ok = false
          error_text = error_text.merge alert_recipient.errors.messages
        end
      end
    end
    return internal_users_ok,external_users_ok,error_text
  end

end
