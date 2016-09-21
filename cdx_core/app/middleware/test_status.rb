class TestStatus
  class << self
    def change_status(test_result)
      test_result.requested_test.update(status: :completed)
    end
  end
end
