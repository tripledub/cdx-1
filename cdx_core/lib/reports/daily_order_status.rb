module Reports
  # Pie chart with total # of tests by type
  class DailyOrderStatus
    def initialize(context, filter_options = {})
      @context = context
      @filter_options = filter_options
      @data = []
    end

    def generate_chart
      all_tests_finder
      {
        columns: @data.each_with_index.map do |slice, i|
          { y: slice[:_value], color: slice_colors[i], indexLabel: "#{slice[:_label]} #percent%", legendText: slice[:_label] }
        end
      }
    end

    private

    def all_tests_finder
      patient_results = PatientResults::Finder.new(@context, @filter_options)
      patient_results.filter_query
                     .group('patient_results.result_status')
                     .order('patient_results.result_status')
                     .select('patient_results.result_status as status, COUNT(*) as total, 1 as uuid').each do |result|
        @data << { _label: I18n.t('select.patient_result.status_options.' + result.status), _value: result.total }
      end
      orphan_results = TestResults::Finder.new(@context, @filter_options)
      orphan_results.filter_query
                     .group('patient_results.result_status')
                     .order('patient_results.result_status')
                     .select('patient_results.result_status as status, COUNT(*) as total, 1 as uuid, 1 as custom_fields, 1 as core_fields').each do |result|
        @data << { _label: I18n.t('select.patient_result.status_options.' + result.status), _value: result.total }
      end
    end

    def slice_colors
      ['#21C334', '#aaaaaa', '#00A8AB', '#B7D6B7', '#D8B49C', '#DE6023', '#47B04B', '#009788', '#A05D56', '#D0743C', '#FF8C00']
    end
  end
end
