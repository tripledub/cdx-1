module Reports
  class AverageSiteTests < Base
    def process
      filter['group_by'] = "site.uuid,#{day_or_month}(test.reported_time)"
      super
    end

    def generate_chart
      automatic_results = process
      manual_results    = get_manual_results_query(automatic_results.filter).select('count(*) as total, sites.uuid, patient_results.created_at').group("sites.uuid, #{day_or_month}(patient_results.created_at)")
      results           = merge_results(automatic_results, manual_results)

      {
        title:   '',
        titleY:  'Peak Tests',
        titleY2: 'Average Tests',
        columns: generate_columns(results.results['tests'])
      }
    end

    private

    def calculate_average(result)
      period = number_of_months > 1 ? number_of_months : number_of_days
      (result['count'].to_f / period)
    end

    def calculate_peak(uuid)
      peak_value = 0

      tests = period_results['tests'].group_by do |t|
        Date.parse(t['test']['start_time']).strftime(format)
      end

      tests.each do |test_group|
        cnt = test_group[1].select { |site| site['uuid'] = uuid }.count
        peak_value = cnt if cnt > peak_value
      end

      peak_value
    end

    def format
      day_or_month == 'day' ? '%Y-%m-%d' : '%Y-%m'
    end

    def lookup_site(uuid)
      site = ::Site.where(uuid: uuid).first
      return site.name.truncate(20) if site
    end

    def period_results
      filter.delete('group_by')
      @period_results ||= TestResult.query(filter, current_user).execute
      manual_results    = get_manual_results_query(filter).select('sites.uuid, patient_results.created_at')
      merge_peak_results(manual_results)
      @period_results
    end

    def generate_columns(results)
      [
        {
          bevelEnabled: false,
          type: "column",
          color: "#E06023",
          name: "Peak tests",
          legendText: "Peak",
          showInLegend: true,
          dataPoints: results.map { |result| { label: lookup_site(result['site.uuid']), y: calculate_peak(result['site.uuid']) } }
        },
        {
          bevelEnabled: false,
          type: "column",
          color: "#5C5B82",
          name: "Average tests",
          legendText: "Average",
          axisYType: "secondary",
          showInLegend: true,
          dataPoints: results.map { |result| { label: lookup_site(result['site.uuid']), y: calculate_average(result) } }
        }
      ]
    end

    def merge_results(test_results, manual_results)
      manual_results.each do |manual_result|
        result_added = false
        test_results.results['tests'].each do |auto_test|
          if auto_test['site.uuid'] == manual_result.uuid
            auto_test['count'] += manual_result.total
            result_added = true
          end
        end

        test_results.results['tests'] << { 'site.uuid' => manual_result.uuid, 'test.reported_time' => manual_result.created_at.strftime("%Y-%m-%d"), 'count' => manual_result.total } unless result_added
      end

      test_results
    end

    def merge_peak_results(manual_results)
      manual_results.each do |manual_result|
        @period_results['tests'] <<
          { 'test' => {
          'start_time' => manual_result.created_at.strftime("%Y-%m-%d"),
          'site' => { 'uuid' => manual_result.uuid }
        } }
      end
    end
  end
end
