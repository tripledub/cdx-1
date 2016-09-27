module Reports
  class Results
    attr_reader :current_user, :context, :options

    def initialize(current_user, context, options = {})
      @current_user = current_user
      @context      = context
      @options      = options
    end

    protected

    def setup
      @query_joins      = {}
      @query_conditions = {}
      @query_or         = []
      filter_by_institution_or_site
      filter_by_date
    end

    def filter_by_institution_or_site
      if context.institution
        @query_joins.merge!({ encounter: :institution })
        @query_conditions.merge!({ 'institutions.uuid': context.institution.uuid })
      elsif context.site
        @query_joins.merge!({ encounter: :site })
        @query_conditions.merge!({ 'sites.uuid': context.site.uuid })
      end
    end

    def filter_by_date
      @query_conditions.merge!({'patient_results.created_at': report_since..report_to})
    end

    def report_since
      begin
        Date.parse(options['date_range']['start_time']['gte']).beginning_of_day
      rescue
        (Date.today - 1.year).beginning_of_day
      end
    end

    def report_to
      begin
        Date.parse(options['date_range']['start_time']['lte']).end_of_day
      rescue
        Date.today.end_of_day
      end
    end

    def run_query
      XpertResult.joins(@query_joins).where(@query_conditions).where(@query_or).count
    end

    def slice_colors
      ["#21C334", "#C90D0D", "#aaaaaa", "#00A8AB", "#B7D6B7", "#D8B49C", "#DE6023", "#47B04B", "#009788", "#A05D56", "#D0743C", "#FF8C00"]
    end
  end
end
