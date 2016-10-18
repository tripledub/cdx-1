class IntegrationLogsController < ApplicationController
  def index
    list_logs = IntegrationLog.all
    order_by, offset  = perform_pagination('integration_logs.updated_at')
    @total = list_logs.count
    
    respond_to do |format|
      format.html do
        @integration_logs = list_logs.order(order_by).limit(@page_size).offset(offset)
      end
    end
  end
  
  def show
    render json: {message: "Retry again with #{params[:id]}"}
  end

  def retry
    log = IntegrationLog.where(id: params[:id], status: ["In progress", "Error"]).first
    if log
      RetryJob.perform_later()
      render json: {success: true}
    else
      render json: {success: false}
    end
  end
end
