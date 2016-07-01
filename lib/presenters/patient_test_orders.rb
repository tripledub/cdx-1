class Presenters::PatientTestOrders
  class << self
    def patient_view(test_orders)
      test_orders.map do |test_order|
        {
          id:          test_order.uuid,
          siteName:    site_name(test_order.site),
          requester:   requester_name(test_order.user),
          requestDate: Extras::Dates::Format.datetime_with_time_zone(test_order.start_time),
          dueDate:     Extras::Dates::Format.datetime_with_time_zone(test_order.testdue_date),
          status:      test_order.core_fields['status'],
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
  end
end
