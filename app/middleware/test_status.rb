class TestStatus
  class << self
    def change_status(test_result)
      update_requested_test_status(test_result.requested_test)
      EncounterStatus.change_status(test_result.requested_test.encounter)
    end

    protected

    def update_requested_test_status(requested_test)
      requested_test.update(status: :completed)
    end
  end
end
