class EncounterStatus
  class << self
    def change_status(encounter)
      if all_tests_finished?(encounter)
        encounter.update(status: :completed)
      else
        encounter.update(status: :inprogress)
      end
    end

    protected

    def all_tests_finished?(encounter)
      encounter.requested_tests.all? { |rt| rt.status == 'completed' || rt.status == 'rejected' }
    end
  end
end
