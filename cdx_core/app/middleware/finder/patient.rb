module Finder
  class Patient
    class << self
      def find_by_institution(institution, current_user)
        Policy.authorize(Policy::Actions::READ_PATIENT, institution.patients, current_user)
      end
    end
  end
end
