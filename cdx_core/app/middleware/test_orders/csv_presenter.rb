module TestOrders
  # Generates a csv for each test order with all the different changes in status
  class CsvPresenter
    attr_reader :filename

    def initialize(test_orders)
      @test_orders = test_orders
    end

    def filename
      @filename || "test_orders_status-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def export_all
      CSV.generate do |csv|
        csv << header
        @test_orders.map { |test_order| add_order_log(csv, test_order) }
      end
    end

    def export_one
      CSV.generate do |csv|
        csv << header
        csv << content
      end
    end

    protected

    def header
      [
        I18n.t('test_orders.state.order_id'),
        I18n.t('test_orders.state.old_state'),
        I18n.t('test_orders.state.new_state'),
        I18n.t('test_orders.state.created_at'),
      ]
    end

    def add_order_log(csv, test_order)
      AuditUpdates::Finder.status_updates_by_test_order(test_order).each do |audit_update|
        csv << [
          test_order.batch_id,
          audit_update.old_value,
          audit_update.new_value,
          Extras::Dates::Format.datetime_with_time_zone(audit_update.created_at)
        ]
      end
    end
  end
end
