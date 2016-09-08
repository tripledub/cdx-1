class Presenters::PatientTestOrders
  class << self
    def patient_view(test_orders)
      test_orders.map do |test_order|
        {
          id:          test_order.uuid,
          batchId:     test_order.batch_id,
          siteName:    site_name(test_order.site),
          performingSiteName:    site_name(test_order.performing_site),
          requester:   requester_name(test_order.user),
          requestDate: Extras::Dates::Format.datetime_with_time_zone(test_order.start_time),
          dueDate:     Extras::Dates::Format.datetime_with_time_zone(test_order.testdue_date),
          status:      convert_status(test_order.status),
          statusRaw:  test_order.status,
          viewLink:    Rails.application.routes.url_helpers.encounter_path(test_order)
        }
      end
    end

    protected

    def site_name(site)
      site.present? ? site.name : '-'
    end

    def requester_name(user)
      user.present? ? user.full_name : '-'
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
