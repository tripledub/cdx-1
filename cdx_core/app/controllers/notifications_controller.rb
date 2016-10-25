class NotificationsController < ApplicationController

  before_action :find_notification

  def index
    @notifications = check_access(Notification, READ_ALERT)
    @notifications = @notifications.within(@navigation_context.entity, @navigation_context.exclude_subsites)

    @can_create = has_access?(Notification, CREATE_ALERT)

    @total = @notifications.count
    order_by, offset = perform_pagination('notifications.last_notification_at')

    @notifications = @notifications.order(order_by)
                           .offset(offset)
                           .limit(@page_size)
    respond_to do |format|
      format.html
      format.json { @notifications }
    end
  end

  def new
    @notification = @navigation_context.institution.notifications.build
    @notification.user = current_user
    notification_form_variables
    encounter_notification
  end

  def edit
    notification_form_variables
  end

  def create
    @notification = @navigation_context.institution.notifications.build(notification_params)
    @notification.user = current_user

    if @notification.save
      redirect_to(edit_alert_group_path(@notification), notice: I18n.t('notifications.flash.create_success'))
    else
      notification_form_variables
      flash.now[:alert] = I18n.t('notifications.flash.create_failure')
      render action: :new
    end
  end

  def update
    if @notification.update_attributes(notification_params)
      redirect_to(edit_alert_group_path(@notification), notice: I18n.t('notifications.flash.update_success'))
    else
      notification_form_variables
      flash.now[:alert] = I18n.t('notifications.flash.update_failure')
      render action: :edit
    end
  end

  def destroy
    @notification.destroy
    redirect_to(alert_groups_path, notice: I18n.t('notifications.flash.destroy_success'))
  end

  def notification_form_variables
    @sites = check_access(Site.within(@navigation_context.entity), READ_SITE)
    @roles = check_access(Role, READ_ROLE)
    @devices = check_access(Device.within(@navigation_context.entity), READ_DEVICE)

    @notification_recipient = @notification.notification_recipients.build

    @conditions = Condition.all
    @condition_results = Cdx::Fields.test.core_fields.find { |field| field.name == 'result' }.options
    # Note: in case you need to specify the exact N/A: @condition_result_statuses = Cdx::Fields.test.core_fields.find { |field| field.name == 'status' }.options

    # Find all users in all roles
    user_ids = @roles.map { |user| user.id }
    user_ids = user_ids.uniq
    @users = User.where(id: user_ids)
  end

  private

    def encounter_notification
      return if params[:encounter_id].blank?
      @encounter = @navigation_context.institution.encounters.where('uuid = :encounter_id', params).first || @navigation_context.institution.encounters.where('id = :encounter_id', params).first
      return unless authorize_resource(@encounter, READ_ENCOUNTER)

      if @encounter
        @notification.name = "Alert for Encounter #{@encounter.batch_id || @encounter.id}"
        @notification.encounter_id = @notification.test_identifier = @encounter.id
        @notification.site_ids << @notification.encounter.site.id
        @notification.user_ids << @notification.encounter.user.id
      end
    end

    def find_notification
      return if params[:id].blank?
      @notification = @navigation_context.institution.notifications.find(params[:id])
    end

    def notification_params
      params.require(:notification).permit(
        :enabled,
        :name,
        :description,
        :patient_identifier,
        :test_identifier,
        :sample_identifier,
        :detection,
        :detection_condition,
        :detection_quantitative_result,
        :device_error_code,
        :anomaly_type,
        :utilisation_efficiency_sample_identifier,
        :utilisation_efficiency_threshold,
        :email,
        :email_limit,
        :email_message,
        :sms,
        :sms_limit,
        :sms_message,
        :frequency,
        :frequency_value,
        notification_recipients_attributes: [ :id, :first_name, :last_name, :email, :telephone, :_destroy ],
        notification_statuses_names: [],
        site_ids:   [],
        device_ids: [],
        role_ids:   [],
        user_ids:   []
      )
    end

end
