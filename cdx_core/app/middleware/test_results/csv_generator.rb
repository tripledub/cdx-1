module TestResults
  # Csv generator for test results
  class CsvGenerator
    attr_reader :filename

    def initialize(selected_tab, params, current_user, navigation_context, localization_helper)
      @selected_tab = selected_tab
      @params = params
      @current_user = current_user
      @navigation_context = navigation_context
      @localization_helper = localization_helper
      @filename = "#{selected_tab}_results-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def create
      case @selected_tab
      when 'microscopy'
        MicroscopyResults::Presenter.csv_query(generate(::Finder::MicroscopyResults))
      when 'xpert'
        XpertResults::Presenter.csv_query(generate(::Finder::XpertResults))
      when 'culture'
        CultureResults::Presenter.csv_query(generate(::Finder::CultureResults))
      when 'dst_lpa'
        DstLpaResults::Presenter.csv_query(generate(::Finder::DstLpaResults))
      else
        ::Finder::TestResults.new(@params, @current_user, @navigation_context, @localization_helper).csv_query(@filename)
      end
    end

    protected

    def generate(results_finder)
      patient_results = results_finder.new(@params, @navigation_context)
      order_by = @params['order_by'] || 'patient_results.sample_collected_at desc'
      patient_results.filter_query.order(order_by)
    end
  end
end
