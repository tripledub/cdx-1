class Presenters::TestOrders
  class << self
    include PatientsHelper

    def index_view(encounters)
      encounters.map do |encounter|
        {
          id:                 encounter.uuid,
          requestedSiteName:  site_name(encounter.site),
          performingSiteName: site_name(encounter.performing_site),
          sampleId:           encounter.samples.map(&:entity_ids).join(', '),
          testingFor:         patient_display_name(encounter.patient.name),
          requestedBy:        encounter.user.full_name,
          requestDate:        Extras::Dates::Format.datetime_with_time_zone(encounter.start_time),
          dueDate:            Extras::Dates::Format.datetime_with_time_zone(encounter.testdue_date),
          status:             convert_status(encounter.status),
          viewLink:           Rails.application.routes.url_helpers.encounter_path(encounter)
        }
      end
    end

    protected

    def site_name(site)
      return '' unless site

      site.name
    end

    def convert_status(status)
      case status
      when 'pending'
        I18n.t('encounters.status.pending')
      when 'inprogress'
        I18n.t('encounters.status.in_progress')
      when 'completed'
        I18n.t('encounters.status.completed')
      end
    end
  end
end
