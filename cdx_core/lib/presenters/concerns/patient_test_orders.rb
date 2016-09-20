module Presenters
  module Concerns
    module PatientTestOrders
      extend ActiveSupport::Concern
      included do
      end

      class_methods do
        def patient_view(test_orders)
          test_orders.map do |test_order|
            {
              id:                 encounter.uuid,
              requestedSiteName:  site_name(encounter.site),
              performingSiteName: site_name(encounter.performing_site),
              sampleId:           encounter.samples.map(&:entity_ids).join(', '),
              testingFor:         encounter.testing_for,
              requestedBy:        encounter.user.full_name,
              batchId:            encounter.batch_id,
              requestDate:        Extras::Dates::Format.datetime_with_time_zone(encounter.start_time),
              dueDate:            Extras::Dates::Format.datetime_with_time_zone(encounter.testdue_date),
              status:             generate_status(encounter),
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
          encounter_status = case encounter.status
          when 'pending'
            I18n.t('encounters.status.pending')
          when 'inprogress'
            I18n.t('encounters.status.in_progress')
          when 'completed'
            I18n.t('encounters.status.completed')
          else
            I18n.t('encounters.status.new')
          end
          encounter_status += ': '

          encounter_status += encounter.requested_tests.map do |requested_test|
            "#{requested_test.result_type} (#{I18n.t('requested_test.status.'+requested_test.status)})"
          end.join(' - ')

          encounter_status
        end
      end
    end
  end
end
