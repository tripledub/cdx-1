class PatientTestOrdersController

  protected

  def set_order_from_params
    order = params[:order] == 'true' ? 'asc' : 'desc'
    case params[:field].to_s
    when 'site'
      "sites.name #{order}"
    when 'orderId'
      "encounters.uuid #{order}"
    when 'requester'
      "users.first_name #{order}, users.last_name"
    when 'status'
      "encounters.status #{order}"
    when 'performingSite'
      "performing_sites.name #{order}"
    else
      "encounters.start_time #{order}"
    end
  end
end
