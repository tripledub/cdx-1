module Reports
  class Site < Base
    def process
      filter['group_by'] = 'day(test.start_time),site.uuid'
      super
    end

    def sites
      site_uuids.inject({}) { |h, uuid| h[uuid] = lookup_site(uuid); h }
    end

    def sort_by_site
      site_results.map do |uuid, results|
        {site_name: sites[uuid], count: count_total(results), uuid: uuid }
      end
    end

    def generate_chart
      automatic_results = process
      manual_results    = get_manual_results_query(automatic_results).group('sites.uuid').count
      found_data        = automatic_results.sort_by_site
      results           = merge_results(found_data, manual_results)
      all_sites         = Policy.authorize Policy::Actions::READ_SITE, ::Site.within(@context.entity), @current_user
      sites             = all_sites.map { | site | [site.name,0] }
      data              = []
      sites.each do | site |
        found_data.each do | found_site_data |
          data << { label: site[0], y: found_site_data[:count] } if found_site_data[:uuid] && site[0].include?(found_site_data[:site_name])
        end
      end
      { titleY2: 'Companies', columns: data }
    end

    private

    def lookup_site(uuid)
      site = ::Site.where(uuid: uuid).first
      return site.name if site
    end

    def site_results
      results['tests'].group_by { |t| t['site.uuid'] }
    end

    def site_uuids
      site_results.keys
    end

    def merge_results(test_results, manual_results)
      manual_results.each do |key, value|
        result_added = false
        test_results.each do |auto_test|
          if auto_test[:uuid] == key
            auto_test[:count] += value
            result_added = true
          end
        end

        test_results << { :uuid => key, :site_name => lookup_site(key), :count => value } unless result_added

      end

      test_results
    end
  end
end
