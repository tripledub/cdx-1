module HeaderNavHelper
  def is_menu_item_active?(menu_item, params)
    is_active = case menu_item
    when 'dashboards'
      params[:controller] == 'dashboards'
    when 'patients'
      params[:controller] == 'patients'
    when 'test_orders'
      params[:controller] == 'test_orders'
    when 'test_results'
      params[:controller] == 'test_results'
    when 'devices'
      params[:controller] == 'devices'
    when 'settings'
      ['roles', 'policies', 'alerts', 'incidents', 'device_messages', 'alert_messages', 'device_models', 'users'].include?(params[:controller]) || params[:action] == "settings"
    else
      false
    end

    is_active ? 'active' : ''
  end
end
