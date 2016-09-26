module Finder
  class TestResults
    attr_reader :params, :filter, :page, :page_size

    class << self
      # TODO this should be converted into instance methods
      def find_by_institution(institution, current_user)
        Policy.authorize(Policy::Actions::QUERY_TEST, TestResult, current_user).where(institution: institution)
      end

      def as_json_list(test_results, localization_helper)
        Jbuilder.new do |json|
          json.array! test_results do |test|
            test.as_json(json, localization_helper)
          end
        end
      end
    end

    def initialize(params, current_user, navigation_context, localization_helper)
      @localization_helper = localization_helper
      @params              = params
      @navigation_context  = navigation_context
      @current_user        = current_user
      @filter              = create_filter_for_test
    end

    def get_results
      execute_test_query
    end

    def total
      @result["total_count"]
    end

    def order_by
      @query["order_by"]
    end

    def json
      build_json_array(TestResult, @result["tests"])
    end

    def csv_query(filename)
      query    = filter.dup
      csv_query = TestResult.query(query, @current_user)
      EntityCsvBuilder.new("test", csv_query, filename)
    end

    protected

    def execute_test_query
      @query               = filter.dup
      @page_size           = (params["page_size"] || 10).to_i
      @page_size           = 50 if @page_size > 100
      @page                = (params["page"] || 1).to_i
      @page                = 1 if @page < 1
      @query["order_by"]   = params["order_by"] || "test.end_time"
      @query["page_size"]  = @page_size
      @query["offset"]     = (@page - 1) * @page_size
      @result = TestResult.query(@query, @current_user).execute
    end

    def create_filter_for_test
      filter = create_filter_for_navigation_context
      if params["device.uuid"].present?
        filter["device.uuid"] = params["device.uuid"]
        device                = Device.find_by_uuid params["device.uuid"]
        filter["site.uuid"]   = device.site.uuid if device.try(:site)
      end
      filter["test.assays.condition"] = params["test.assays.condition"] if params["test.assays.condition"].present?
      filter["test.assays.result"]    = params["test.assays.result"] if params["test.assays.result"].present?
      filter["test.type"]             = params["test.type"] if params["test.type"].present?
      filter["sample.id"]             = params["sample.id"] if params["sample.id"].present?

      filter["since"]       = params["since"] if params["since"].present?
      filter["since"]       = params["from_date"] if params["from_date"].present?
      filter["until"]       = params["to_date"] if params["to_date"].present?
      filter["test.status"] = params["test.status"] if params["test.status"].present?

      filter
    end

    def create_filter_for_navigation_context
      filter = {}
      filter["institution.uuid"] = @navigation_context.institution.uuid if @navigation_context.institution
      if @navigation_context.exclude_subsites && @navigation_context.site
        filter["site.uuid"] = @navigation_context.site.uuid
      elsif !@navigation_context.exclude_subsites && @navigation_context.site
        # site.path is used in order to select entitites of descending sites also
        filter["site.path"] = @navigation_context.site.uuid
      elsif @navigation_context.exclude_subsites
        filter["site.uuid"] = "null"
      end
      filter
    end

    def build_json_array(entity_class, tests)
      json = Jbuilder.new do |json|
        json.array! tests do |test|
          entity_class.as_json_from_query(json, test, @localization_helper)
        end
      end
      json.attributes!
    end
  end
end
