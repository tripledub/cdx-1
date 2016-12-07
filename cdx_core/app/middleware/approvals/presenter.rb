module Approvals
  # Format approvals list
  class Presenter
    class << self
      include PatientsHelper

      def index_view(encounters)
        encounters.map do |encounter|
          {
            id:                 encounter.uuid,
            requestedSiteName:  Sites::Presenter.site_name(encounter.site),
            performingSiteName: Sites::Presenter.site_name(encounter.performing_site),
            sampleId:           SampleIdentifiers::Presenter.for_encounter(encounter),
            testingFor:         encounter.testing_for,
            requestedBy:        encounter.user.full_name,
            batchId:            encounter.batch_id,
            requestDate:        Extras::Dates::Format.datetime_with_time_zone(encounter.created_at, :full_time),
            testsRequiringApproval: encounter.tests_requiring_approval,
            status:             generate_status(encounter),
            viewLink:           Rails.application.routes.url_helpers.encounter_path(encounter)
          }
        end
      end

      protected

      def generate_status(encounter)
        encounter_status = I18n.t("select.encounter.status_options.#{encounter.status}")
        encounter_status += ': '

        encounter_status += encounter.patient_results.map do |patient_result|
          "#{patient_result.test_name} (#{I18n.t('select.patient_result.status_options.' + patient_result.result_status)})"
        end.join(' - ')

        encounter_status
      end
    end
  end
end
