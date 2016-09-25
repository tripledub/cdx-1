class ApprovalsController < TestsController

  def index
    respond_to do |format|
      format.html do
        execute_encounter_query
      end

      format.csv do
        filename                       = "test-orders-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
        headers["Content-Type"]        = "text/csv"
        headers["Content-disposition"] = "attachment; filename=#{filename}"
        self.response_body             = execute_csv_test_order_query(create_filter_for_test_order.dup, filename)
      end
    end
  end

  protected

  def execute_encounter_query
    params['patient_result_status'] = 'pending_approval'
    @approvals = TestOrders::Finder.new(@navigation_context, params)

    @total = @approvals.filter_query.count
    order_by, offset = perform_pagination('encounters.start_time')

    @approvals = @approvals.filter_query.order(order_by)
                           .offset(offset)
                           .limit(@page_size)
  end

  def execute_csv_test_order_query(query, filename, csv=false)
    query = Encounter.query(query, current_user)
    EntityCsvBuilder.new("encounter", query, filename)
  end

  def create_filter_for_test_order
    filter = {}
    filter["encounter.uuid"] = params['selectedItems'] if params['selectedItems'].present?
    filter
  end
end