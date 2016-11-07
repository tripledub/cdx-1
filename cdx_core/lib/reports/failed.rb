module Reports
  # Pie chart with total # of tests and total # of failed tests.
  class Failed
    def initialize(context, filter_options = {})
      @context = context
      @filter_options = filter_options
      @data = []
      @total_tests = 0
      @failed_tests = 0
    end

    def generate_chart
      all_tests_finder
      failed_tests_finder
      sort_pie
      {
        columns: @data.each_with_index.map do |slice, i|
          { y: slice[:_value], color: slice_colors[i], indexLabel: "#{slice[:_label]} #percent%", legendText: slice[:_label] }
        end
      }
    end

    private

    def all_tests_finder

      patient_results = PatientResults::Finder.new(@context, @filter_options)
      @total_tests += patient_results.filter_query.count
      orphan_results = TestResults::Finder.new(@context, @filter_options)
      @total_tests += orphan_results.filter_query.count
    end

    def failed_tests_finder
      @filter_options['failed'] = true
      patient_results = PatientResults::Finder.new(@context, @filter_options)
      @failed_tests += patient_results.filter_query.count
      orphan_results = TestResults::Finder.new(@context, @filter_options)
      @failed_tests += orphan_results.filter_query.count
    end

    def sort_pie
      @data << { _label: I18n.t('failed.success'), _value: @total_tests - @failed_tests }
      @data << { _label: I18n.t('failed.fail'), _value: @failed_tests }
    end

    def slice_colors
      ['#21C334', '#C90D0D', '#aaaaaa', '#00A8AB', '#B7D6B7', '#D8B49C', '#DE6023', '#47B04B', '#009788', '#A05D56', '#D0743C', '#FF8C00']
    end
  end
end
