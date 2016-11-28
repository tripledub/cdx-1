# Test results controller
class TestResultsController < TestsController
  include Policy::Actions

  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  before_action :clean_params
  before_action :set_filter_params, only: [:index]
  before_action :find_test_result, only: [:show]
  before_action :check_permission, only: [:show]

  def index
    @date_options = Extras::Dates::Filters.date_options_for_filter

    respond_to do |format|
      format.html do
        @can_create_encounter = !check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER).empty?
        case @selected_tab
        when 'microscopy'
          load_test_results(Finder::MicroscopyResults, MicroscopyResults::Presenter, 'microscopy_results_index')
        when 'xpert'
          load_test_results(Finder::XpertResults, XpertResults::Presenter, 'xpert_results_index')
        when 'culture'
          load_test_results(Finder::CultureResults, CultureResults::Presenter, 'culture_results_index')
        when 'dst_lpa'
          load_test_results(Finder::DstLpaResults, DstLpaResults::Presenter, 'dstlpa_results_index')
        else
          load_test_results(TestResults::Finder, TestResults::Presenter, 'orphan_results_index')
        end

        cookies[:test_result_tab] = { value: @selected_tab, expires: 1.year.from_now }
      end

      format.csv do
        csv_content = TestResults::CsvGenerator.new(@selected_tab, params, @navigation_context, get_hostname)
        headers['Content-Type'] = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_content.filename}"
        self.response_body = csv_content.create
      end
    end
  end

  def show
    @other_tests       = @test_result.sample ? @test_result.sample.test_results.where.not(id: @test_result.id) : TestResult.none
    @core_fields_scope = Cdx::Fields.test.core_field_scopes.detect{ |x| x.name == 'test' }
    @samples           = @test_result.sample_identifiers.reject{ |identifier| identifier.entity_id.blank? }.map { |identifier| [identifier.entity_id, Barby::Code93.new(identifier.entity_id)] }
    @show_institution  = show_institution?(Policy::Actions::QUERY_TEST, TestResult)

    device_messages  = @test_result.device_messages.joins(device: :device_model)
    @total           = device_messages.count
    order_by, offset = perform_pagination(table: 'patient_show_result_index', field_name: '-device_messages.created_at')
    @device_messages = DeviceMessages::Presenter.index_view(device_messages.order(order_by).limit(@page_size).offset(offset))
  end

  protected

  def load_test_results(results_finder, presenter, table_name)
    patient_results   = results_finder.new(@navigation_context, params)
    @total            = patient_results.filter_query.count
    order_by, offset  = perform_pagination(table: table_name, field_name: '-patient_results.sample_collected_at')
    @test_results     = presenter.index_table(patient_results.filter_query.order(order_by).limit(@page_size).offset(offset))
  end

  def default_selected_tab
    params['test_results_tabs_selected_tab'] || cookies[:test_result_tab] || 'devices'
  end

  def clean_params
    params.delete(:controller)
    params.delete(:action)
  end

  def set_filter_params
    @selected_tab = default_selected_tab
    filter_model = if @selected_tab == 'devices'
                     'Device'
                   elsif @selected_tab == 'dst_lpa'
                     'DstLpa'
                   else
                     @selected_tab.capitalize
                   end

    set_filter_from_params("FilterData::#{filter_model}Results".constantize)
  end

  def find_test_result
    @test_result = @navigation_context.institution.test_results.where(id: params[:id]).first
  end

  def check_permission
    redirect_to(test_results_path) unless @test_result && has_access?(@test_result, QUERY_TEST)
  end

  def get_hostname
    request.host || 'www.thecdx.org'
  end
end
