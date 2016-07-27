class TestStatus
  class << self
    def change_status(test_result)
      update_requested_test_status(test_result.requested_test)
      update_test_order_status(test_result.requested_test.encounter)
    end

    protected

    def update_requested_test_status(requested_test)
      requested_test.update(status: :completed)
    end

    def update_test_order_status(encounter)
      if all_tests_finished?(encounter)
        encounter.update(status: :completed)
      else
        encounter.update(status: :inprogress)
      end
    end

    def all_tests_finished?(encounter)
      encounter.requested_tests.all? { |rt| rt.status == 'completed' || rt.status == 'rejected' }
    end
  end
end
