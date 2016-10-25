module Notifications
  class Presenter
    class << self
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper

      def index_table(notifications)
        notifications.map do |notification|
          {
            id:           notification.id,
            name:         truncate(notification.name, length: 20),
            description:  truncate(notification.description, length: 20),
            enabled:      show_enabled(notification.enabled),
            sites:        notification.sites.map(&:name).join(', '),
            roles:        notification.roles.map(&:name).join(', '),
            lastIncident: notification.last_notification_at,
            viewLink:     Rails.application.routes.url_helpers.edit_alert_group_path(notification)
          }
        end
      end

      protected

        def show_enabled(enabled)
          enabled ? I18n.t('views.say_yes') : I18n.t('views.say_no')
        end
    end
  end
end
