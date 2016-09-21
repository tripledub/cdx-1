class SubscribersController < ApplicationController
  include Concerns::SubscribersController
  skip_before_action :ensure_context

  respond_to :html, :json
  expose(:subscribers) do
    if params[:filter_id]
      current_user.filters.find(params[:filter_id]).subscribers
    else
      current_user.subscribers
    end
  end
  expose(:subscriber, attributes: :subscriber_params)
  expose(:filters) { current_user.filters }
  before_filter do
    head :forbidden unless has_access_to_test_results_index?
  end

  def index
    respond_with subscribers
  end

  def show
    respond_with subscriber
  end

  def edit
    @editing = true
  end

  def new
    redirect_to subscribers_path if filters.empty?

    subscriber.fields = []
  end

  def create
    subscriber.last_run_at = Time.now
    flash[:notice] = I18n.t('subscribers_controller.subscriber_created') if subscriber.save
    respond_with subscriber, location: subscribers_path
  end

  def update
    flash[:notice] = I18n.t('subscribers_controller.subscriber_updated') if subscriber.save
    respond_with subscriber, location: subscribers_path
  end

  def destroy
    subscriber.destroy
    respond_with subscriber
  end
end
