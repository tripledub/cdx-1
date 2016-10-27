module Patients
  # CdxVietnam override presenter methods for patients
  class Presenter
    class << self
      def show_full_address(patient_address)
        return '' unless patient_address.present?

        address = []
        address << patient_address.address
        address << patient_address.city
        address << Address.regions.to_h[patient_address.state] || patient_address.state
        address << patient_address.country
        address << patient_address.zip_code
        address.reject(&:blank?).join(', ')
      end
    end
  end
end
