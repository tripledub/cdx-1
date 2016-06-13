class Cdx::Alert::Conditions::Percolator
  def initialize(params, alert_info)
    @params                 = params
    @alert_info             = alert_info
    @external_users_ok      = true
    @internal_users_ok      = true
    @condition_result_ok    = true
    @alert_saved_ok         = true
    @alert_query_updated_ok = true
  end

  def create(current_user)
    @alert_info.user                          = current_user
    @alert_info.time_last_aggregation_checked = Time.now

    @alert_saved_ok = @alert_info.save
    if @alert_saved_ok == false
      error_text = @alert_info.errors.messages
    else
      @alert_info.query = {}
      edit = false
      set_channel_info(edit)
      set_category(edit)
      Cdx::Alert::Conditions::Sample.new(@alert_info, alert_params[:sample_id]).create
      set_sites_devices_institutions(edit)
      only_allow_specimen_test_type
      @alert_query_updated_ok = @alert_info.save
    end
  end

  def update
    @alert_saved_ok = @alert_info.save

    if @alert_saved_ok == false
      @error_text = @alert_info.errors.messages
    else
      #note: the update in the alert model calls create
      if @alert_info.enabled == false
        @alert_info.delete_percolator
      end

      @alert_info.query = {}
      edit             = true
      set_channel_info(edit)

      set_category(edit)
      Cdx::Alert::Conditions::Sample.new(@alert_info, alert_params[:sample_id]).create
      set_sites_devices_institutions(edit)
      @alert_query_updated_ok = @alert_info.save
    end

    valid?
  end

  def error_text
    @error_text || Hash.new
  end

  protected

  def valid?
    @alert_saved_ok && @alert_query_updated_ok && @external_users_ok && @internal_users_ok && @condition_result_ok
  end

  def set_channel_info(is_edit)
    #destroy all recipients before adding them in again on an update

    if (is_edit==true)
      AlertRecipient.destroy_all(alert_id: @alert_info.id)
    end

    if alert_params[:roles]
      results_info = Cdx::Alert::Conditions::Roles.new(@alert_info, alert_params[:roles])
      results_info.create

      unless results_info.roles_ok
        condition_result_ok = false
        error_text          = error_text.merge results_info.error_text
      end
    end

    #save internal users
    if alert_params[:users_info]
      results_info = Cdx::Alert::Conditions::InternalUsers.new(@alert_info, alert_params[:users_info])
      results_info.create

      unless results_info.internal_users_ok
        @condition_result_ok = false
        error_text          = error_text.merge results_info.error_text
      end
    end

    #save external users
    if alert_params[:external_users]
      results_info = Cdx::Alert::Conditions::ExternalUsers.new(@alert_info, alert_params[:external_users])
      results_info.create

      unless results_info.external_users_ok
        @condition_result_ok = false
        error_text          = error_text.merge results_info.error_text
      end
    end
  end

  def set_category(is_edit)
    if is_edit==true
      @alert_info.conditions.destroy_all
    end

    if @alert_info.category_type == "anomalies"
      if @alert_info.anomalie_type == "missing_sample_id"
        @alert_info.query = {"sample.id"=>"null"}
      end
    elsif @alert_info.category_type == "device_errors"
      if @alert_info.error_code && (@alert_info.error_code.include? '-')
        minmax=@alert_info.error_code.split('-')
        @alert_info.query =    {"test.error_code.min" => minmax[0], "test.error_code.max"=>minmax[1]}
        #elsif @alert_info.error_code.include? '*'
        #   @alert_info.query =    {"test.error_code.wildcard" => "*7"}
      else
        @alert_info.query = {"test.error_code"=>@alert_info.error_code }
      end
    elsif @alert_info.category_type == "test_results"
      #this will generate a query like: core_fields: {"assays" =>["condition" => "mtb", "result" => :positive]}

      query_conditions = Cdx::Alert::Conditions::Info.new(@alert_info, alert_params[:conditions_info]).create

      if alert_params[:condition_results_info]
        results_info            = Cdx::Alert::Conditions::ResultsInfo.new(@alert_info, alert_params[:condition_results_info])
        query_condition_results = results_info.create

        unless results_info.condition_result_ok
          @condition_result_ok = false
          error_text          = error_text.merge results_info.error_text
        end
      end

      @alert_info.query= { "test.assays.condition" => query_conditions, "test.assays.result" => query_condition_results }
      #TEST  @alert_info.query =    {"assays.quantitative_result.min" => "8"}
      #TEST  @alert_info.query =    {"test.assays.condition" => query_conditions, "test.assays.quantitative_result.min" => "8"}

    elsif @alert_info.category_type == "utilization_efficiency"
      @alert_info.aggregation_type = Alert.aggregation_types.key(1)  #for utilization, it is always an aggregation
      @alert_info.utilization_efficiency_last_checked = Time.now
      #Note: the sampleid must be set for this category -in a validation
    end
  end

  def set_sites_devices_institutions(is_edit)
    if is_edit==true
      @alert_info.devices.destroy_all
      @alert_info.sites.destroy_all
    end

    Cdx::Alert::Conditions::Institutions.new(@alert_info).create
    Cdx::Alert::Conditions::SitesInfo.new(@alert_info, alert_params[:sites_info]).create if alert_params[:sites_info]
    #TODO you have the device uuid, you don’t even need the site uuid
    Cdx::Alert::Conditions::Devices.new(@alert_info, alert_params[:devices_info]).create if alert_params[:devices_info]
    Cdx::Alert::Conditions::Threshold.new(@alert_info, threshold_params).create

    #Note: @alert_info.create_percolator is called from the model
  end

  def only_allow_specimen_test_type
    @alert_info.query.merge!({ "test.type" => "specimen" })
  end

  def alert_params
    @params[:alert]
  end

  def threshold_params
    { min: alert_params['test_result_min_threshold'], max: alert_params['test_result_max_threshold'] }
  end
end
