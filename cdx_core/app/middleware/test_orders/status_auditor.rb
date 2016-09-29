module TestOrders
  # Audit all status changes individually
  # A new audit log is created for each test order and each status change is recorded as an update for that log.
  class StatusAuditor
    class << self
      def create_status_log(test_order, values)
        Audit::Auditor.new(test_order).log_status_change('t{encounters.update.status_tracking}', values)
      end
    end
  end
end
