# Exports test orders status updates.
class TestOrdersStateController < ApplicationController
  respond_to :csv, only: [:index, :show]

  before_action :check_permission

  before_action :find_test_order, only: [:show]

  def index
    params['audit_logs'] = true
    params['status'] = 'all'
    test_orders = TestOrders::Finder.new(@navigation_context, params)
    respond_to do |format|
      format.csv do
        csv_file = TestOrders::AuditCsv.new(test_orders.filter_query, get_hostname)
        headers['Content-Type']        = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export_all
      end
    end
  end

  def show
    respond_to do |format|
      format.csv do
        csv_file = TestOrders::AuditCsv.new(@test_order, get_hostname)
        headers['Content-Type']        = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export_one
      end
    end
  end

  def patients
    patients = Patients::Finder.new(current_user, @navigation_context, params).filter_query
    respond_to do |format|
      format.csv do
        csv_file = Patients::ListCsv.new(patients, get_hostname)
        headers['Content-Type']        = 'text/csv'
        headers['Content-disposition'] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.export
      end
    end
  end

  protected

  def find_test_order
    @test_order = @navigation_context.institution.encounters.find(params[:id])
  end

  def check_permission
    authorize_resource(@navigation_context.institution, UPDATE_INSTITUTION)
  end

  def get_hostname
    request.host || 'www.thecdx.org'
  end
end
