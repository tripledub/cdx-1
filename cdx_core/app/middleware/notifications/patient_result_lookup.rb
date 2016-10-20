module Notifications
  class PatientResultLookup < Notifications::BaseLookup
    def check_notifications
      @notifications =
        Notification.enabled
                    .includes(:institution, :sites, :notification_statuses, :patient)
                    .where(institutions: { id: alertable.institution_id })

      @notifications =
        @notifications.where('notification_statuses.id is null OR notification_statuses.test_status = ?', alertable.result_status)

      if alertable.site
        @notifications = @notifications.where('sites.id is null OR sites.id = ?', alertable.site.id)
      elsif alertable.encounter && alertable.encounter.site
        @notifications = @notifications.where('sites.id is null OR sites.id = ?', alertable.encounter.site.id)
      else
        @notifications = @notifications.where('sites.id is null')
      end

      if alertable.encounter
        @notifications =
          @notifications.where('notifications.encounter_id is null OR notifications.encounter_id = ?', alertable.encounter.id)
      else
        @notifications = @notifications.where('notifications.encounter_id is null')
      end

      if alertable.patient
        @notifications = @notifications.where('patients.id is null OR patients.id = ?', alertable.patient.id)
      else
        @notifications = @notifications.where('patients.id is null')
      end
    end

    def self.check_notifications(lookup)
      new(lookup.alertable, lookup.changed_attributes)
        .check_notifications
    end
  end
end
