class Presenters::PatientTestOrders
  class << self
    def patient_view(test_orders)
      test_orders.map do |test_order|
        {
          id:          test_order.uuid,
          siteName:    site_name(test_order.site),
          requester:   requester_name(test_order.user),
          requestDate: format_time(test_order.start_time),
          dueDate:     format_time(test_order.testdue_date),
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

    def format_time(timeValue)
      return '' unless timeValue.present?

      timeValue.is_a?(String) ? I18n.l(Time.parse(timeValue), format: :short) : I18n.l(timeValue, format: :short)
    end
  end
end
