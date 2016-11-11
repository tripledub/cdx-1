module Reports
  # Generates a bar graphic with all test results grouped for a period of time.
  class AllTests
    def initialize(context, filter_options = {})
      @context = context
      @filter_options = filter_options
      @days_span = 0
      @merged_results = {}
    end

    def generate_chart
      {
        title:   '',
        titleY:  I18n.t('all_tests.number_tests'),
        titleY2: I18n.t('all_tests.number_errors'),
        axisX: {
          labelAngle: -50,
          labelFontFamily: 'Verdana',
          labelFontSize: 12
        },
        columns: columns_data
      }
    end

    private

    def columns_data
      find_results
      [total_results_column, error_results_column]
    end

    def total_results_column
      {
        bevelEnabled: false,
        type: 'column',
        color: '#E06023',
        name: 'Tests',
        legendText: I18n.t('all_tests.tests'),
        showInLegend: true,
        dataPoints: @merged_results.map { |result| { label: result[0], y: result[1][:total] } }
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
        dataPoints: @merged_results.map { |result| { label: result[0], y: result[1][:errors] } }
      }
    end

    def find_results
      patient_results_finder.each { |result| add_result(result.date, result.total, 0) }
      orphan_results_finder.each { |result| add_result(result.date, result.total, 0) }
      find_error_results
      @merged_results = Hash[@merged_results.sort]
    end

    def find_error_results
      @filter_options['status'] = 'error'
      patient_results_finder.each { |result| add_result(result.date, 0, result.total) }
      orphan_results_finder.each { |result| add_result(result.date, 0, result.total) }
    end

    def patient_results_finder
      patient_results = PatientResults::Finder.new(@context, @filter_options)
      @days_span = patient_results.number_of_days
      patient_results.filter_query
                     .group(dates_filter)
                     .order('patient_results.result_at')
                     .select('patient_results.result_at as date, COUNT(*) as total, 1 as uuid')
    end

    def orphan_results_finder
      orphan_results = TestResults::Finder.new(@context, @filter_options)
      orphan_results.filter_query
                    .group(dates_filter)
                    .order('patient_results.result_at')
                    .select('patient_results.result_at as date, COUNT(*) as total, 1 as uuid, "" as custom_fields, "" as core_fields ')
    end

    def merge_results(test_results, manual_results)
      test_results.merge(manual_results) { |_k, test_value, manual_value| test_value + manual_value }
    end

    def dates_filter
      @days_span > 30 ? 'month(patient_results.result_at)' : 'date(patient_results.result_at)'
    end

    def dates_format
      @days_span > 30 ? '%Y-%m (%b)' : '%Y-%m-%d'
    end

    def add_result(date, total, errors)
      return unless date.present?

      date = date.strftime(dates_format)
      if @merged_results[date]
        @merged_results[date][:total] += total
        @merged_results[date][:errors] += errors
      else
        @merged_results[date] = { total: total, errors: errors }
      end
    end
  end
end
