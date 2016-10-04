module Concerns
  module TestOrders
    module Presenter
      extend ActiveSupport::Concern
      included do
      end

      class_methods do
        include PatientsHelper

        def index_view(encounters)
          encounters.map do |encounter|
            {
              id:                 encounter.uuid,
              requestedSiteName:  site_name(encounter.site),
              performingSiteName: site_name(encounter.performing_site),
              sampleId:           samples_for_encounter(encounter),
              testingFor:         encounter.testing_for,
              requestedBy:        encounter.user.full_name,
              batchId:            encounter.batch_id,
              requestDate:        Extras::Dates::Format.datetime_with_time_zone(encounter.start_time),
              dueDate:            Extras::Dates::Format.datetime_with_time_zone(encounter.testdue_date),
              status:             generate_status(encounter),
              paymentDone:        encounter.payment_done,
              viewLink:           Rails.application.routes.url_helpers.encounter_path(encounter)
            }
          end
        end

        protected

        def site_name(site)
          return '' unless site

          site.name
        end

        def generate_status(encounter)
          encounter_status = I18n.t("select.encounter.status_options.#{encounter.status}")
          encounter_status += ': '

          encounter_status += encounter.patient_results.map do |patient_result|
            "#{patient_result.test_name} (#{I18n.t('select.patient_result.status_options.'+patient_result.result_status)})"
          end.join(' - ')

          encounter_status
        end

        def samples_for_encounter(encounter)
          encounter.patient_results.map { |patient_result| patient_result.serial_number }.join(', ')
        end
      end
    end
  end
end
