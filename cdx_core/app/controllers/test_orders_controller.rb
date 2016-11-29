# Test orders controller
class TestOrdersController < TestsController
  before_action :set_filter_params, only: [:index]

  def index
    respond_to do |format|
      format.html do
        execute_encounter_query
      end

      format.csv do
        csv_orders = TestOrders::ListCsv.new(TestOrders::Finder.new(@navigation_context, params).filter_query, get_hostname)
        headers['Content-Type'] = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_orders.filename}"
        self.response_body = csv_orders.generate
      end
    end
  end

  protected

  def execute_encounter_query
    test_orders = TestOrders::Finder.new(@navigation_context, params)
    @total = test_orders.filter_query.count
    order_by, offset = perform_pagination(table: 'test_orders_index', field_name: 'encounters.testdue_date')
    order_by += ', users.last_name' if order_by.include?('users.first_name')
    @tests = test_orders.filter_query.order(order_by).limit(@page_size).offset(offset)
  end

  def create_filter_for_test_order
    filter = {}
    filter['encounter.uuid'] = params['selectedItems'] if params['selectedItems'].present?
    filter
  end

  def set_filter_params
    set_filter_from_params(FilterData::TestOrders)
  end
end
