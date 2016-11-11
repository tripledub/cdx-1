class ApprovalsController < TestsController

  def index
    respond_to do |format|
      format.html do
        execute_encounter_query
      end

      format.csv do
        csv_orders = TestOrders::ListCsv.new(TestOrders::Finder.new(@navigation_context, params).filter_query)
        headers['Content-Type'] = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_orders.filename}"
        self.response_body = csv_orders.generate
      end
    end
  end

  protected

  def execute_encounter_query
    params['patient_result_status'] = 'pending_approval'
    @approvals = TestOrders::Finder.new(@navigation_context, params)

    @total = @approvals.filter_query.count
    order_by, offset = perform_pagination(table: 'approvals_index', field_name: 'encounters.start_time')

    @approvals = @approvals.filter_query.order(order_by)
                           .offset(offset)
                           .limit(@page_size)
  end

  def create_filter_for_test_order
    filter = {}
    filter["encounter.uuid"] = params['selectedItems'] if params['selectedItems'].present?
    filter
  end
end
