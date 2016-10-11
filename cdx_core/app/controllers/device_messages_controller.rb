class DeviceMessagesController < ApplicationController
  before_filter :load_message, only: [:raw, :reprocess]

  def index
    device_ids = check_access(Device, SUPPORT_DEVICE).within(@navigation_context.entity, @navigation_context.exclude_subsites).pluck(:id)
    @messages = DeviceMessage.where("device_id IN (?)", device_ids).joins(device: :device_model).reverse_order
    apply_filters
    @date_options = Extras::Dates::Filters.date_options_for_filter
    @devices = check_access(Device, READ_DEVICE).within(@navigation_context.entity)
    @device_models = DeviceModel.all
  end

  def raw
    return unless authorize_resource(@message.device, READ_DEVICE)
    ext, type = case @message.device.current_manifest.data_type
    when 'json'
      ['json', 'application/json']
    when 'csv', 'headless_csv'
      ['csv', 'text/csv']
    when 'xml'
      ['xml', 'application/xml']
    else
      ['txt', 'text/plain']
    end

    send_data @message.plain_text_data, filename: "message_#{@message.id}.#{ext}", type: type
  end

  def reprocess
    return unless authorize_resource(@message.device, READ_DEVICE)
    @message.reprocess
    redirect_to device_messages_path, notice: I18n.t('device_messages.reprocess.message_reprocess')
  end

  private

  def apply_filters
    @messages = @messages.where("devices.uuid = ?", params["device.uuid"])               if params["device.uuid"].present?
    @messages = @messages.where("device_models.id = ?", params["device_model"])          if params["device_model"].present?
    @messages = @messages.where("index_failure_reason LIKE ?", "%#{params["message"]}%") if params["message"].present?
    @messages = @messages.where("device_messages.created_at > ?", params["created_at"])  if params["created_at"].present?

    @total           = @messages.count
    @page_size       = (params["page_size"] || 10).to_i
    @page_size       = 100 if @page_size > 100
    @page            = (params["page"] || 1).to_i
    @page            = 1 if @page < 1
    @order_by        = params["order_by"] || "-device_messages.created_at"
    offset           = (@page - 1) * @page_size
    @device_messages = DeviceMessages::Presenter.index_view(@messages.order(@order_by).limit(@page_size).offset(offset))
  end

  def load_message
    @message = DeviceMessage.find(params[:id])
  end
end
