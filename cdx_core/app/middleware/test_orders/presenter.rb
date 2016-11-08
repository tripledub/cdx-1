module TestOrders
  # Handles the presentation of a test order
  class Presenter
    class << self
      include PatientsHelper

      def index_view(encounters)
        fetch_rows(encounters)
      end

      def patient_view(encounters, order_by)
        encounters_data = {}
        encounters_data['rows'] = fetch_rows(encounters)
        encounters_data['pages'] = {
          totalPages: encounters.total_pages,
          currentPage: encounters.current_page,
          firstPage: encounters.first_page?,
          lastPage: encounters.last_page?,
          prevPage: encounters.prev_page,
          nextPage: encounters.next_page
        }
        encounters_data['order_by'] = order_by
        encounters_data
      end

      protected

      def fetch_rows(encounters)
        encounters.map do |encounter|
          {
            id:                 encounter.uuid,
            requestedSiteName:  Sites::Presenter.site_name(encounter.site),
            performingSiteName: Sites::Presenter.site_name(encounter.performing_site),
            sampleId:           samples_for_encounter(encounter),
            testingFor:         encounter.testing_for,
            requestedBy:        encounter.user.full_name,
            batchId:            encounter.batch_id,
            requestDate:        Extras::Dates::Format.datetime_with_time_zone(encounter.start_time, :full_time),
            dueDate:            Extras::Dates::Format.datetime_with_time_zone(encounter.testdue_date, :full_date),
            status:             generate_status(encounter),
            viewLink:           Rails.application.routes.url_helpers.encounter_path(encounter)
          }
        end
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
        encounter.samples.map { |sample| sample.sample_identifiers.map(&:cpd_id_sample) }.compact.join(', ')
      end
    end
  end
end
