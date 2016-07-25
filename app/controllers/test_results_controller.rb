class TestResultsController < TestsController
  include Policy::Actions

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  def index
    respond_to do |format|
      format.html do
        @can_create_encounter = check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER).size > 0
        case params['profile_tabs_selected_tab']
        when 'microscopy'
          load_manual_test_results(Finder::MicroscopyResults, Presenters::MicroscopyResults)
        when 'xpert'
          load_manual_test_results(Finder::XpertResults, Presenters::XpertResults)
        when 'culture'
          load_manual_test_results(Finder::CultureResults, Presenters::CultureResults)
        when 'dst'
          load_manual_test_results(Finder::DstLpaResults, Presenters::DstLpaResults)
        else
          load_device_test_results
        end
      end

      format.csv do
        filename                       = "test_results-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
        headers["Content-Type"]        = "text/csv"
        headers["Content-disposition"] = "attachment; filename=#{filename}"
        self.response_body             = execute_csv_test_query(filename)
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

  def execute_csv_test_query(filename)
    query = TestResult.query(@query, current_user)
    EntityCsvBuilder.new("test", query, filename)
  end

  def load_manual_test_results(results_finder, presenter)
    patient_results   = results_finder.new(params, @navigation_context)
    @total            = patient_results.filter_query.count
    order_by, offset  = perform_pagination('patient_results.updated_at desc')
    @test_results     = presenter.index_table(patient_results.filter_query.order(order_by).limit(@page_size).offset(offset))
  end

  def load_device_test_results
    @results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options.map do |result|
      if result == "n/a"
        {value: 'n/a', label: 'Not Applicable'}
      else
        {value: result, label: result.capitalize}
      end
    end
    @test_types    = Cdx::Fields.test.core_fields.find { |field| field.name == 'type' }.options
    @test_statuses = ['success','error']
    @conditions    = Condition.all.map &:name
    @date_options  = Extras::Dates::Filters.date_options_for_filter
    @show_sites   = @sites.size > 1
    @show_devices = @devices.size > 1

    @device_results       = Finder::TestResults.new(params, current_user, @navigation_context, @localization_helper)
    @page                 = @device_results.page
    @total                = @device_results.total
    @page_size            = @device_results.page_size
  end
end
