class Presenters::PatientTestOrders
  include Present::Concerns::PatientTestOrders
  class << self
    alias_method :core_patient_view, :patient_view

    def patient_view(test_orders)
      core_patient_view(test_orders).each { |test_order|
        test_order.delete(:batchId)
        test_order.delete(:dueDate)
      }
    end
  end
end
