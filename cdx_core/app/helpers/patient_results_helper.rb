# Helpers for patient test results
module PatientResultsHelper
  def show_approval_buttons?(result, current_user)
    result.pending_approval? && Policy.can?(Policy::Actions::APPROVE_ENCOUNTER, Encounter, current_user)
  end
end
