module Reports
  # Generates a bar graphic with all test results grouped for a period of time.
  class AllTests
    attr_reader :statuses

    def initialize(current_user, context, options = {})
      @filter = {}
      @current_user = current_user
      @context = context
      @data = []
      @options = options
    end

    def generate_chart
      #automatic_results = process

      #results           = merge_results(automatic_results, manual_results)

      # sorted_data = results.number_of_months > 1 ? results.sort_by_month.data : results.sort_by_day.data

      {
        title:   '',
        titleY:  I18n.t('all_tests.number_tests'),
        titleY2: I18n.t('all_tests.number_errors'),
        axisX: {
          valueFormatString: 'DD-MM-YY',
          labelAngle: -50,
          labelFontFamily: 'Verdana',
          labelFontSize: 12
        },
        columns: columns_data
      }
    end

    private

    def columns_data
      [
        {
          bevelEnabled: false,
          type: "column",
          color: "#E06023",
          name: "Tests",
          legendText: I18n.t('all_tests.tests'),
          showInLegend: true,
          dataPoints: find_results
        },
        {
          bevelEnabled: false,
          type: "column",
          color: "#5C5B82",
          name: "Errors",
          legendText: I18n.t('all_tests.errors'),
          axisYType: "secondary",
          showInLegend: true,
          dataPoints: find_error_results
        }
      ]
    end

    def find_results
      merged_results = {}
      merged_results.default_proc = proc { 0 }
      patient_results = patient_results_finder
      orphan_results  = orphan_results_finder
      patient_results_finder.each { |result| merged_results[result.date.strftime('%Y-%m-%d')] += result.total }
      orphan_results_finder.each { |result| merged_results[result.date.strftime('%Y-%m-%d')] += result.total }
      merged_results.map { |key, value| { label: key, y: value } }
    end

    def find_error_results
      @options['status'] = 'error'
      find_results
    end

    def patient_results_finder
      PatientResults::Finder.new(@context, @options)
        .filter_query
        .group('date(patient_results.created_at)')
        .order('patient_results.created_at')
        .select('patient_results.created_at as date, COUNT(*) as total, 1 as uuid')
    end

    def orphan_results_finder
      TestResults::Finder.new(@context, @options)
        .filter_query
        .group('date(patient_results.result_at)')
        .order('patient_results.result_at')
        .select('patient_results.result_at as date, COUNT(*) as total, 1 as uuid, "" as custom_fields, "" as core_fields ')
    end

    def merge_results(test_results, manual_results)
      test_results.merge(manual_results){ |k, t_value, m_value| t_value + m_value }
    end
  end
end
