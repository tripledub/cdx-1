class TestResultsController < TestsController
  include Policy::Actions

  before_filter :load_filter_resources

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  def index
    @results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options.map do |result|
      if result == "n/a"
        {value: 'n/a', label: 'Not Applicable'}
      else
        {value: result, label: result.capitalize}
      end
    end
    @test_types = Cdx::Fields.test.core_fields.find { |field| field.name == 'type' }.options
    @test_statuses = ['success','error']
    @conditions = Condition.all.map &:name
    @date_options = Extras::Dates::Filters.date_options_for_filter

    @page_size = (params["page_size"] || 10).to_i
    @page = (params["page"] || 1).to_i
    offset = (@page - 1) * @page_size

    @filter = create_filter_for_test
    @query = @filter.dup
    @order_by = params["order_by"] || "test.end_time"
    @query["order_by"] = @order_by

    @show_sites = @sites.size > 1
    @show_devices = @devices.size > 1

    respond_to do |format|
      format.html do
        @query["page_size"] = @page_size
        @query["offset"] = offset
        @filter["device.uuid"] = @devices.first.uuid if @devices.size == 1
        @can_create_encounter = check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER).size > 0
        execute_test_query
      end

      format.csv do
        filename = "test_results-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
        headers["Content-Type"] = "text/csv"
        headers["Content-disposition"] = "attachment; filename=#{filename}"
        self.response_body = execute_csv_test_query(filename)
      end
    end
  end

  def show
    @test_result       = TestResult.find_by(uuid: params[:id])
    return unless authorize_resource(@test_result, QUERY_TEST)

    @other_tests       = @test_result.sample ? @test_result.sample.test_results.where.not(id: @test_result.id) : TestResult.none
    @core_fields_scope = Cdx::Fields.test.core_field_scopes.detect{|x| x.name == 'test'}

    @samples          = @test_result.sample_identifiers.reject{|identifier| identifier.entity_id.blank?}.map {|identifier| [identifier.entity_id, Barby::Code93.new(identifier.entity_id)]}
    @show_institution = show_institution?(Policy::Actions::QUERY_TEST, TestResult)

    device_messages  = DeviceMessage.where(device_id: @test_result.device_id).joins(device: :device_model)
    @total           = device_messages.count
    @page_size       = (params["page_size"] || 10).to_i
    @page_size       = 100 if @page_size > 100
    @page            = (params["page"] || 1).to_i
    @page            = 1 if @page < 1
    @order_by        = params["order_by"] || "-device_messages.created_at"
    offset           = (@page - 1) * @page_size
    @device_messages = Presenters::DeviceMessages.index_view(device_messages.order(@order_by).limit(@page_size).offset(offset))
  end

  private

  def create_filter_for_test
    filter = create_filter_for_navigation_context
    if params["device.uuid"].present?
      filter["device.uuid"] = params["device.uuid"]
      # display only test results of the current site of the device
      device = Device.find_by_uuid params["device.uuid"]
      filter["site.uuid"] = device.site.uuid if device.try(:site)
    end
    filter["test.assays.condition"] = params["test.assays.condition"] if params["test.assays.condition"].present?
    filter["test.assays.result"] = params["test.assays.result"] if params["test.assays.result"].present?
    filter["test.type"] = params["test.type"] if params["test.type"].present?
    filter["sample.id"] = params["sample.id"] if params["sample.id"].present?
    filter["since"] = params["since"] if params["since"].present?
    filter["test.status"] = params["test.status"] if params["test.status"].present?

    filter
  end



  def create_filter_for_navigation_context
    filter = {}
    filter["institution.uuid"] = @navigation_context.institution.uuid if @navigation_context.institution
    if @navigation_context.exclude_subsites && @navigation_context.site
      filter["site.uuid"] = @navigation_context.site.uuid
    elsif !@navigation_context.exclude_subsites && @navigation_context.site
      # site.path is used in order to select entitites of descending sites also
      filter["site.path"] = @navigation_context.site.uuid
    elsif @navigation_context.exclude_subsites
      filter["site.uuid"] = "null"
    end
    filter
  end


  def execute_test_query
    result = TestResult.query(@query, current_user).execute
    @total = result["total_count"]
    @tests = result["tests"]
    @json = build_json_array TestResult, @tests
  end

  def execute_encounter_query
    result = Encounter.query(@query, current_user).execute
    @total = result["total_count"]
    build_table_data(result["encounters"])
  end

  def build_json_array(entity_class, tests)
    json = Jbuilder.new do |json|
      json.array! tests do |test|
        entity_class.as_json_from_query(json, test, @localization_helper)
      end
    end
    json.attributes!
  end

  def execute_csv_test_query(filename)
    query = TestResult.query(@query, current_user)
    EntityCsvBuilder.new("test", query, filename)
  end
end
