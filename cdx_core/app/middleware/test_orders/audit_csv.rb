module TestOrders
  # Generates a csv for each test order with all the different changes in status
  class AuditCsv
    attr_reader :filename

    def initialize(test_orders, hostname)
      @test_orders = test_orders
      @hostname = hostname
    end

    def filename
      @filename || "#{@hostname}_test_orders_status-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def export_all
      CSV.generate do |csv|
        csv << [
          I18n.t('test_orders.state.order_id'),
          I18n.t('test_orders.state.old_state'),
          I18n.t('test_orders.state.new_state'),
          I18n.t('test_orders.state.created_at'),
          I18n.t('test_orders.state.patient_id')
        ]
        @test_orders.map { |test_order| add_order_log(csv, test_order) }
      end
    end

    def export_one
      CSV.generate do |csv|
        csv << [
          I18n.t('test_orders.state.order_id'),
          I18n.t('test_orders.state.sample_id'),
          I18n.t('test_orders.state.old_state'),
          I18n.t('test_orders.state.new_state'),
          I18n.t('test_orders.state.created_at'),
          I18n.t('test_orders.state.patient_id')
        ]
        @test_orders.patient_results.map { |patient_result| add_results_log(csv, patient_result) }
      end
    end

    protected

    def add_order_log(csv, test_order)
      AuditUpdates::Finder.status_updates_by_test_order(test_order).each do |audit_update|
        csv << [
          test_order.batch_id,
          audit_update.old_value,
          audit_update.new_value,
          Extras::Dates::Format.datetime_with_time_zone(audit_update.created_at, :full_time),
          test_order.patient.id.to_s
        ] if audit_update.old_value != audit_update.new_value
      end
    end

    def add_results_log(csv, patient_result)
      AuditUpdates::Finder.status_updates_by_patient_result(patient_result).each do |audit_update|
        csv << [
          patient_result.encounter.batch_id,
          patient_result.serial_number,
          audit_update.old_value,
          audit_update.new_value,
          Extras::Dates::Format.datetime_with_time_zone(audit_update.created_at, :full_time),
          patient_result.encounter.patient.id.to_s
        ] if audit_update.old_value != audit_update.new_value
      end
    end
  end
end
