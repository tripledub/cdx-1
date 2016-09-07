class EncounterStatus
  class << self
    def change_status(encounter)
      if all_tests_finished?(encounter)
        encounter.update(status: :completed)
      elsif all_tests_pending?(encounter)
        encounter.update(status: :pending)
      else
        encounter.update(status: :inprogress)
      end
    end

    protected

    def all_tests_finished?(encounter)
      encounter.requested_tests.all? { |rt| rt.status == 'completed' || rt.status == 'rejected' }
    end

    def all_tests_pending?(encounter)
      encounter.requested_tests.all? { |rt| rt.status == 'pending' }
    end
  end
end
