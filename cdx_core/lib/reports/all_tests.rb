module Reports
  # Generates a bar graphic with all test results grouped for a period of time.
  class AllTests
    def initialize(context, options = {})
      @context = context
      @options = options
      @days_span = 0
    end

    def generate_chart
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
      [total_results_column, error_results_column]
    # If there is some problem with data we don't want to send a 500 error to the dashboard page
    rescue
      []
    end

    def total_results_column
      {
        bevelEnabled: false,
        type: 'column',
        color: '#E06023',
        name: 'Tests',
        legendText: I18n.t('all_tests.tests'),
        showInLegend: true,
        dataPoints: find_results
      }
    end

    def error_results_column
      {
        bevelEnabled: false,
        type: 'column',
        color: '#5C5B82',
        name: 'Errors',
        legendText: I18n.t('all_tests.errors'),
        axisYType: 'secondary',
        showInLegend: true,
        dataPoints: find_error_results
      }
    end

    def find_results
      merged_results = {}
      merged_results.default_proc = proc { 0 }
      patient_results_finder.each { |result| merged_results[result.date.strftime(dates_format)] += result.total }
      orphan_results_finder.each { |result| merged_results[result.date.strftime(dates_format)] += result.total }
      merged_results.map { |key, value| { label: key, y: value } }
    end

    def find_error_results
      @options['status'] = 'error'
      find_results
    end

    def patient_results_finder
      patient_results = PatientResults::Finder.new(@context, @options)
      @days_span = patient_results.number_of_days
      patient_results.filter_query
                     .group(dates_filter)
                     .order('patient_results.created_at DESC')
                     .select('patient_results.created_at as date, COUNT(*) as total, 1 as uuid')
    end

    def orphan_results_finder
      orphan_results = TestResults::Finder.new(@context, @options)
      orphan_results.filter_query
                    .group(dates_filter)
                    .order('patient_results.result_at DESC')
                    .select('patient_results.result_at as date, COUNT(*) as total, 1 as uuid, "" as custom_fields, "" as core_fields ')
    end

    def merge_results(test_results, manual_results)
      test_results.merge(manual_results) { |_k, test_value, manual_value| test_value + manual_value }
    end

    def dates_filter
      @days_span > 30 ? 'month(patient_results.result_at)' : 'date(patient_results.result_at)'
    end

    def dates_format
      @days_span > 30 ? '%Y-%b' : '%Y-%m-%d'
    end
  end
end
