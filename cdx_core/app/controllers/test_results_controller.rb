# Test results controller
class TestResultsController < TestsController
  include Policy::Actions

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  def index
    @date_options = Extras::Dates::Filters.date_options_for_filter

    respond_to do |format|
      format.html do
        @can_create_encounter = !check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER).empty?
        @selected_tab         = default_selected_tab
        case @selected_tab
        when 'microscopy'
          load_manual_test_results(Finder::MicroscopyResults, MicroscopyResults::Presenter)
        when 'xpert'
          load_manual_test_results(Finder::XpertResults, XpertResults::Presenter)
        when 'culture'
          load_manual_test_results(Finder::CultureResults, CultureResults::Presenter)
        when 'dst_lpa'
          load_manual_test_results(Finder::DstLpaResults, DstLpaResults::Presenter)
        else
          load_device_test_results
        end

        cookies[:test_result_tab] = { value: @selected_tab, expires: 1.year.from_now }
      end

      format.csv do
        csv_content = TestResults::CsvGenerator.new(@selected_tab, params, current_user, @navigation_context, @localization_helper)
        headers['Content-Type']        = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_content.filename}"
        self.response_body             = csv_content.create
      end
    end
  end

  def show
    @test_result = TestResult.find_by(uuid: params[:id])
    return unless authorize_resource(@test_result, QUERY_TEST)

    @other_tests       = @test_result.sample ? @test_result.sample.test_results.where.not(id: @test_result.id) : TestResult.none
    @core_fields_scope = Cdx::Fields.test.core_field_scopes.detect{|x| x.name == 'test'}
    @samples           = @test_result.sample_identifiers.reject{|identifier| identifier.entity_id.blank?}.map {|identifier| [identifier.entity_id, Barby::Code93.new(identifier.entity_id)]}
    @show_institution  = show_institution?(Policy::Actions::QUERY_TEST, TestResult)

    device_messages  = DeviceMessage.where(device_id: @test_result.device_id).joins(device: :device_model)
    @total           = device_messages.count
    @page_size       = (params["page_size"] || 10).to_i
    @page_size       = 100 if @page_size > 100
    @page            = (params["page"] || 1).to_i
    @page            = 1 if @page < 1
    @order_by        = params["order_by"] || "-device_messages.created_at"
    offset           = (@page - 1) * @page_size
    @device_messages = DeviceMessages::Presenter.index_view(device_messages.order(@order_by).limit(@page_size).offset(offset))
  end

  private

  def load_manual_test_results(results_finder, presenter)
    patient_results   = results_finder.new(params, @navigation_context)
    @total            = patient_results.filter_query.count
    order_by, offset  = perform_pagination('patient_results.sample_collected_at desc')
    @test_results     = presenter.index_table(patient_results.filter_query.order(order_by).limit(@page_size).offset(offset))
  end

  def load_device_test_results
    @results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options.map do |result|
      if result == 'n/a'
        { value: 'n/a', label: I18n.t('test_results_controller.not_applicable') }
      else
        { value: result, label: result.capitalize }
      end
    end

    @test_types    = Cdx::Fields.test.core_fields.find { |field| field.name == 'type' }.options
    @test_statuses = %w(success error)
    @conditions    = Condition.all.map(&:name)
    @show_sites    = @sites.size > 1
    @show_devices  = @devices.size > 1

    @device_results = Finder::TestResults.new(params, current_user, @navigation_context, @localization_helper)
    @device_results.get_results
    @page           = @device_results.page
    @total          = @device_results.total
    @page_size      = @device_results.page_size
  end

  def default_selected_tab
    params['test_results_tabs_selected_tab'] || cookies[:test_result_tab] || 'devices'
  end
end
