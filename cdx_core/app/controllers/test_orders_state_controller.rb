# Exports test orders status updates.
class TestOrdersStateController < ApplicationController
  respond_to :csv, only: [:index, :show]

  def index
    params['audit_logs'] = true
    params['status'] = 'all'
    test_orders = TestOrders::Finder.new(@navigation_context, params)
    respond_to do |format|
      format.csv do
        csv_file = TestOrders::CsvPresenter.new(test_orders.filter_query)
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export_all
      end
    end
  end

  def show
    test_orders = []
    respond_to do |format|
      format.csv do
        csv_file = TestOrders::CsvPresenter.new(test_orders)
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export_one
      end
    end
  end
end
