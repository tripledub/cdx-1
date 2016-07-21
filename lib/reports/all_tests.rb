module Reports
  class AllTests < Base
    def self.by_name(*args)
      new(*args).by_name
    end

    attr_reader :statuses

    def statuses
      results['tests'].group_by { |t| t['test.status'] }.keys
    end

    def process
      filter['group_by'] = 'day(test.start_time),test.status'
      super
    end

    def generate_chart
      automatic_results = process
      manual_results    = get_manual_results_query(automatic_results).group('date(patient_results.created_at)').count
      results           = merge_results(automatic_results, manual_results)

      if results.number_of_months > 1
        sorted_data = results.sort_by_month.data
      else
        sorted_data = results.sort_by_day.data
      end
      {
        title:   '',
        titleY:  'Number of tests',
        titleY2: 'Number of errors',
        columns: generate_columns(sorted_data)
      }
    end

    private

    def data_hash_day(dayname, test_results)
      {
        label: dayname,
        values: statuses.map do |u|
          result = test_results && test_results[u]
          result ? count_total(result) : 0
        end
      }
    end

    def data_hash_month(date, test_results)
      {
        label: label_monthly(date),
        values: statuses.map do |s|
          result = test_results && test_results[s]
          result ? count_total(result) : 0
        end
      }
    end

    def day_results(format='%Y-%m-%d', key)
      results_by_period(format)[key].try do |r|
        r.group_by { |t| t['test.status'] }
      end
    end

    def month_results(format='%Y-%m', key)
      results_by_period(format)[key].try do |r|
        r.group_by { |t| t['test.status'] }
      end
    end

    def generate_columns(sorted_data)
      [
        {
          bevelEnabled: false,
          type: "column",
          color: "#E06023",
          name: "Tests",
          legendText: "Tests",
          showInLegend: true,
          dataPoints: sorted_data.map { |data_point| { label: data_point[:label], y: data_point[:values][0] } }
        },
        {
          bevelEnabled: false,
          type: "column",
          color: "#5C5B82",
          name: "Errors",
          legendText: "Errors",
          axisYType: "secondary",
          showInLegend: true,
          dataPoints: sorted_data.map { |data_point| { label: data_point[:label], y: data_point[:values][1] } }
        }
      ]
    end

    def merge_results(test_results, manual_results)
      manual_results.each do |key, value|
        result_added = false
        test_results.results['tests'].each do |auto_test|
          if auto_test['test.status'] == 'success' && auto_test['test.start_time'] == key.strftime("%Y-%m-%d")
            auto_test['count'] += value
            result_added = true
          end
        end

        test_results.results['tests'] << { 'test.status' => 'success', 'test.start_time' => key.strftime("%Y-%m-%d"), 'count' => value } unless result_added
      end

      test_results
    end
  end
end
