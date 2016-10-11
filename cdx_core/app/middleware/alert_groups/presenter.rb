module AlertGroups
  # Presenter methods for AlertGroups
  class Presenter
    class << self
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::DateHelper

      def index_table(alerts)
        alerts.map do |alert|
          {
            id:           alert.id,
            name:         truncate(alert.name, length: 20),
            description:  truncate(alert.description, length: 20),
            enabled:      show_enabled(alert.enabled),
            sites:        display_sites(alert),
            roles:        display_roles(alert),
            lastIncident: display_latest_alert_date(alert),
            viewLink:     Rails.application.routes.url_helpers.edit_alert_group_path(alert)
          }
        end
      end

      def display_latest_alert_date(alert)
        if alert_history == alert.alert_histories.order(:created_at).last
          time_ago_in_words(alert_history.created_at) + I18n.t('alert_groups.index.ago')
        else
          I18n.t('alert_groups.index.never')
        end
      end

      protected

      def show_enabled(enabled)
        enabled ? I18n.t('views.say_yes') : I18n.t('views.say_no')
      end

      def display_sites(alert)
        return '' unless alert.sites.present?

        alert.sites.map(&:name).join(', ')
      end

      def display_roles(alert)
        role_names = []
        alert.alert_recipients.each do |recipient|
          if AlertRecipient.recipient_types[recipient.recipient_type] == AlertRecipient.recipient_types['role']
            role = Role.where(id: recipient.role_id).first
            role_names << role.name if role
          end
        end
        role_names
      end
    end
  end
end
