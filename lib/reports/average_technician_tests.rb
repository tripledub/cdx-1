module Reports
  class AverageTechnicianTests < Base

    def generate_chart
      average_tests
      {
        title:   '',
        titleY:  'Peak Tests',
        titleY2: 'Average Tests',
        columns: generate_columns
      }
    end

    protected

    def average_tests
      filter['group_by'] = "test.site_user,#{day_or_month}(test.start_time)"
      test_users_list    = []
      automatic_results  = TestResult.query(@filter, current_user).execute
      manual_results     = get_manual_results_query(@filter).joins('INNER JOIN users on users.id = encounters.user_id').select("count(*) as total, '1' as uuid, CONCAT_WS(' ', users.first_name, users.last_name) as site_user, patient_results.created_at").group("site_user, #{day_or_month}(patient_results.created_at)")
      results            = merge_results(automatic_results, manual_results)

      results['tests'].each do |result|
        test_user         = result['test.site_user']
        matched_test_user = test_users_list.find { |x| x[:site_user] == test_user }

        if matched_test_user
          matched_test_user[:total] += result['count']
          matched_test_user[:number_results] += 1
          matched_test_user[:peak] = result['count'] if matched_test_user[:peak] < result['count']
        else
          test_users_list << {
            site_user: test_user,
            total: result['count'],
            peak: result['count'],
            average: 0,
            number_results: 1
          }
        end
      end

      calculate_average(test_users_list)
      data = format_data(test_users_list)
    end

    def calculate_average(test_result_data)
      test_result_data.map do |test_user_data|
        if (test_user_data[:total] > 0) && (test_user_data[:number_results] > 0)
          test_user_data[:average] = test_user_data[:total] / test_user_data[:number_results]
        end
      end
    end

    def format_data(test_result_data)
      test_result_data.map do |test_user_data|
        data << {
          label: test_user_data[:site_user].truncate(20),
          peak: test_user_data[:peak],
          average: test_user_data[:average]
        }
      end
      data
    end

    def generate_columns
      [
        {
          bevelEnabled: false,
          type: "column",
          color: "#E06023",
          name: "Peak tests",
          legendText: "Peak",
          showInLegend: true,
          dataPoints: data.map { |result| { label: result[:label], y: result[:peak] } }
        },
        {
          bevelEnabled: false,
          type: "column",
          color: "#5C5B82",
          name: "Average tests",
          legendText: "Average",
          axisYType: "secondary",
          showInLegend: true,
          dataPoints: data.map { |result| { label: result[:label], y: result[:average] } }
        }
      ]
    end

    def merge_results(test_results, manual_results)
      manual_results.each do |manual_result|
        result_added = false
        test_results['tests'].each do |auto_test|
          if auto_test['test.site_user'] == manual_result.site_user
            auto_test['count'] += manual_result.total
            result_added = true
          end
        end

        test_results['tests'] << { 'test.site_user' => manual_result.site_user, 'test.reported_time' => manual_result.created_at.strftime("%Y-%m-%d"), 'count' => manual_result.total } unless result_added
      end

      test_results
    end
  end
end
