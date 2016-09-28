module Import
  # Import Site data into CDX. If supplied Institution is missing
  # it will also be created
  class Sites < Import::Base
    def clear_data
      # Remove Audit Logs associated with Encounter,
      # otherwise you can't remove the Encounters
      AuditLog.where(encounter_id: Encounter.all).delete_all
      # Remove Encounters, otherwise you can't remove Sites
      Encounter.delete_all
      # Remove Roles
      Role.delete_all
      # Remove Policies
      Policy.delete_all
      # Remove Computed Policies except superadmin
      ComputedPolicy.where.not(user_id: User.first).delete_all
      # Remove Computed Policy Exceptions
      ComputedPolicyException.delete_all
      # Remove Sites
      Site.delete_all
      # Remove Institutions
      Institution.delete_all
    end

    def process_object(object)
      return if object[:institution].blank? || object[:site].blank? && object[:site][:name].blank?

      unless (institution = Institution.where('lower(name) = ?', object[:institution].downcase).first)
        institution = Institution.create!(name: object[:institution], user: User.first)
      end

      site = institution.sites.create!(
        name: object[:site][:name],
        address: object[:site][:address] || 'Acme Place',
        city: object[:site][:city] || 'New City',
        state: object[:site][:state] || 'New City State',
        zip_code: object[:site][:zip_code] || 'ABC 123'
      )
    end
  end
end
