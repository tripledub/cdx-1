# Application controller. Where it all starts.
class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Concerns::Context

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, if: :json_request?

  before_action :authenticate_user!
  before_action :check_no_institution!
  before_action :ensure_context
  before_action :set_locale
  before_action :set_current_user

  def set_locale
    I18n.locale = current_user.try(:locale) || I18n.default_locale
    I18n.locale = params[:language] if params[:language].present?
    @localization_helper = LocalizationHelper.new(
      current_user.try(:time_zone),
      I18n.locale,
      current_user.try(:timestamps_in_device_time_zone)
    )
  end

  decent_configuration do
    strategy DecentExposure::StrongParametersStrategy
  end

  def render_json(object, params = {})
    render params.merge(text: object.to_json_oj, content_type: 'text/json')
  end

  def self.set_institution_tab(key)
    before_filter do
      send :set_institution_tab, key
    end
  end

  def set_institution_tab(key)
    @institution_tab = key
  end

  def authorize_resource(resource, action)
    if has_access?(resource, action)
      check_access(resource, action)
    else
      log_authorization_warn resource, action
      head :forbidden
      nil
    end
  end

  def check_no_institution!
    return if current_user && current_user.need_change_password?

    if current_user && Institution.all.empty? && has_access?(Institution, CREATE_INSTITUTION)
      redirect_to new_institution_path
      return
    end

    if current_user && current_user.institutions.empty? && current_user.policies.empty? && current_user.roles.empty?
      if has_access?(Institution, CREATE_INSTITUTION)
        redirect_to new_institution_path
      else
        redirect_to pending_approval_institutions_path
      end
    end
  end

  def default_url_options(_options = {})
    return { context: params[:context] } if params[:context].present?

    {}
  end

  def after_sign_in_path_for(resource_or_scope)

    # update user locale after signed in
    resource_or_scope.update_attribute('locale', params[:user][:locale]) if params[:user]

    if has_access?(TestResult, Policy::Actions::MEDICAL_DASHBOARD)
      dashboard_path
    elsif has_access_to_sites_index?
      sites_path
    elsif has_access_to_devices_index?
      devices_path
    elsif has_access_to_device_models_index?
      device_models_path
    elsif has_access_to_test_results_index?
      test_results_path
    elsif can_delegate_permissions?
      policies_path
    elsif has_access_to_patients_index?
      patients_path
    elsif has_access_to_users_index?
      users_path
    elsif has_access?(Device, Policy::Actions::SUPPORT_DEVICE)
      device_messages_path
    elsif has_access_to_settings?
      settings_path
    else
      no_data_allowed_institutions_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def nndd
    render text: "NNDD"
  end if Rails.env.test?

  protected

  def json_request?
    request.format.json?
  end

  def perform_pagination(default_order)
    @page_size = (params['page_size'] || 10).to_i
    @page_size = 50 if @page_size > 100
    @page      = (params['page'] || 1).to_i
    @page      = 1 if @page < 1
    @order_by  = params['order_by'] || default_order
    order_by   =  @order_by[0] == '-' ? @order_by[1..90] + ' desc' : @order_by
    offset     = (@page - 1) * @page_size
    [order_by, offset]
  end

  def log_authorization_warn(resource, action)
    resource_name =
      if resource.is_a? Class
        "#{resource} class"
      else
        "#{resource.class} (id=#{resource.id})"
      end
    logger.warn "#{I18n.t('application_controller.authorization_failed')} #{action} #{I18n.t('application_controller.requested_by')} #{current_user.email} #{I18n.t('application_controller.in')} #{resource_name}"
  end

  # Save current user to be able to use it in audit logs callbacks.
  def set_current_user
    User.current = current_user
  end
end
