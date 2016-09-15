module Encounters
  class Status
    class << self
      def change_status(encounter)
        # Update requested tests probably outdated due to transaction issues.
        encounter.requested_tests.reload
        if all_tests_finished?(encounter)
          encounter.update(status: :pending_approval)
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
end
