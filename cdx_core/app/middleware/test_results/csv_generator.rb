module TestResults
  # Csv generator for test results
  class CsvGenerator
    attr_reader :filename

    def initialize(selected_tab, params, navigation_context)
      @selected_tab = selected_tab
      @params = params
      @navigation_context = navigation_context
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
        TestResults::Presenter.csv_query(generate(::TestResults::Finder))
      end
    end

    protected

    def generate(results_finder)
      patient_results = results_finder.new(@navigation_context, @params)
      order_by = @params['order_by'] || 'patient_results.sample_collected_at desc'
      patient_results.filter_query.order(order_by)
    end
  end
end
