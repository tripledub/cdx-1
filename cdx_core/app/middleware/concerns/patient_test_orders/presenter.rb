module Concerns
  module PatientTestOrders
    module Presenter
      extend ActiveSupport::Concern
      included do
      end

      class_methods do
        def patient_view(test_orders)
          test_orders.map do |test_order|
            {
              id:                 test_order.uuid,
              requestedSiteName:  site_name(test_order.site),
              performingSiteName: site_name(test_order.performing_site),
              sampleId:           test_order.samples.map(&:entity_ids).join(', '),
              testingFor:         test_order.testing_for,
              requestedBy:        test_order.user.full_name,
              batchId:            test_order.batch_id,
              requestDate:        Extras::Dates::Format.datetime_with_time_zone(test_order.start_time),
              dueDate:            Extras::Dates::Format.datetime_with_time_zone(test_order.testdue_date),
              status:             generate_status(test_order),
              viewLink:           Rails.application.routes.url_helpers.encounter_path(test_order)
            }
          end
        end

        protected

        def site_name(site)
          return '' unless site

          site.name
        end

        def generate_status(test_order)
          encounter_status = case test_order.status
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

          encounter_status += test_order.requested_tests.map do |requested_test|
            "#{requested_test.result_type} (#{I18n.t('requested_test.status.'+requested_test.status)})"
          end.join(' - ')

          encounter_status
        end
      end
    end
  end
end
