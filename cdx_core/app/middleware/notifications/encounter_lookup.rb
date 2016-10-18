module Notifications
  class EncounterLookup < Notifications::BaseLookup
    def check_notifications
      @notifications =
        Notification.enabled
                    .includes(:institution, :sites, :notification_statuses, :patient)
                    .where(institutions: { id: alertable.institution_id })
                    .where('sites.id is null OR sites.id = ?', alertable.site_id)
                    .where('notification_statuses.id is null OR notification_statuses.test_status = ?', alertable.status)
                    .where('patients.id is null OR patients.id = ?', alertable.patient_id)
                    .where('notifications.sample_identifier is null OR notifications.sample_identifier in (?)', sample_identifier_ids)
    end

    def sample_identifier_ids
      SampleIdentifier.includes(:sample => :encounter).where(encounters: { id: alertable.id }).pluck(:cpd_id_sample)
    end

    def self.prepare_notifications(record_id, changed_attributes = {})
      lookup = new(Encounter.find(record_id), changed_attributes)
      lookup.check_notifications
      lookup.create_notices_from_notifications
      lookup
    end
  end
end
