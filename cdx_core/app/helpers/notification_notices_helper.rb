module NotificationNoticesHelper
  def friendly_data(data)
    @friendly_data ||= data.map do |field, action|
      # "media_used"=>[nil, "solid"]
      if action[0].blank?
        I18n.t('notification_notices.friendly_data.added', field: field.capitalize, to: action[1])
      elsif action[1].blank?
        I18n.t('notification_notices.friendly_data.removed', field: field.capitalize, from: action[0])
      else
        I18n.t('notification_notices.friendly_data.changed', field: field.capitalize, from: action[0], to: action[1])
      end
    end.join(', ')
  end
end
