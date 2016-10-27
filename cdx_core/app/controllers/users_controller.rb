# Users controller
class UsersController < ApplicationController
  before_filter :load_resource, only: [:edit, :update, :assign_role, :unassign_role, :remove, :resend_invite, :find]
  before_action :set_filter_params, only: [:index]

  def index
    site_admin = !has_access?(@navigation_context.entity, READ_INSTITUTION_USERS) && @navigation_context.entity.kind_of?(Institution)
    if site_admin
      ids = check_access(Site.within(@navigation_context.entity), READ_SITE_USERS).pluck(:id)
    end
    redirect_to no_data_allowed_users_path unless has_access?(@navigation_context.entity, (@navigation_context.entity.kind_of?(Institution) ? READ_INSTITUTION_USERS : READ_SITE_USERS)) || !ids.empty?

    @users = User.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @users = @users.where("roles.site_id IN (?)", ids) if site_admin
    @context_roles = Role.within(@navigation_context.entity, @navigation_context.exclude_subsites)
    @available_roles = @context_roles.select do |role|
      has_access?(role, ASSIGN_USER_ROLE)
    end
    @available_roles_hash = @available_roles.map { |r| { value: r.id, label: r.name } }
    @context_roles_hash = @context_roles.map { |r| { value: r.id, label: r.name } }
    @can_update = has_access?(User, UPDATE_USER)
    apply_filters
    @total = @users.count

    @date_options = Extras::Dates::Filters.date_options_for_filter

    respond_to do |format|
      format.html do
        @total = @users.count

        order_by, offset = perform_pagination('users.first_name')
        order_by         = order_by + ', users.last_name' if order_by.include?('users.first_name')
        @users = @users.order(order_by).limit(@page_size).offset(offset)
      end
      format.csv do
        filename = "Users-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
        headers["Content-Type"] = "text/csv"
        headers["Content-disposition"] = "attachment; filename=#{filename}"
        self.response_body = build_csv
      end
    end
  end

  def edit
    @user_roles = @user.roles.select { |role| has_access?(role, ASSIGN_USER_ROLE) }
    @user_roles = @user_roles.map { |r| { value: r.id, label: r.name } }
    @can_update = has_access?(User, UPDATE_USER)
  end

  def update
    return unless authorize_resource(@user, UPDATE_USER)
    return head :forbidden unless can_edit?

    message = I18n.t('users.update.user_updated') if @user.update(user_params)
    redirect_to users_path, notice: message || I18n.t('users.update.user_not_updated')
  end

  def create
    if params[:users] && role = Role.find(params[:role])
      add_users = Persistence::Users.new(current_user)
      add_users.add_and_invite(params[:users], params[:message], role)
      status_message = add_users.status_message
    else
      status_message = I18n.t('users.create.role_not_found')
    end

    render text: { 'info' => status_message }.to_json, layout: false
  end

  def assign_role
    if params[:add]
      @user.roles << Role.find(params[:add].to_i)
    else
      role = Role.find(params[:remove].to_i)
      @user.roles.delete(role)
    end
    # Since user is not being updated here, we need to force the new role's policy update
    ComputedPolicy.update_user(@user)
    render nothing: true
  end

  def autocomplete
    users = User.within(@navigation_context.institution)
                .uniq
                .where("first_name LIKE ? OR last_name LIKE ? OR (email LIKE ? AND first_name IS NULL AND last_name IS NULL)", "%#{params["q"]}%", "%#{params["q"]}%", "%#{params["q"]}%")
                .map{|r| {value: r.email, label: r.full_name}}
    render json: users
  end

  def update_setting
    current_user.update_attributes({sidebar_open: params[:sidebar_open]})
    render nothing: true
  end

  def no_data_allowed
    # the no_data_allowed page make sense when the logged user has no access
    # to the resource selected in the navbar.
    redirect_to users_path if has_access?(
      @navigation_context.entity,
      (@navigation_context.entity.is_a?(Institution) ? READ_INSTITUTION_USERS : READ_SITE_USERS))
  end

  # Remove a specified User based on ID and redirect to the Users list page
  def remove
    #return unless authorize_resource(current_user, UPDATE_USER)
    #return head :forbidden unless can_edit?
    #user = User.find_by(id: params[:id])
    if @user.present?
      @user.destroy
      redirect_to users_path, notice: I18n.t('users.remove.user_removed')
    else
      redirect_to users_path, notice: I18n.t('users.remove.user_not_found')
    end
  end

  # Find a User by their Email address,
  # return a json state of 'success' (if found) or 'fail'.
  # To be used from an Ajax call.
  def find
    user = User.find_by(email: params[:email])
    if user.present?
      render json: 'success'.to_json
    else
      render json: 'fail'.to_json
    end
  end

  # Find the User by ID,
  # attempt to send the Invite email again to them,
  # then redirect back to the Users list page.
  def resend_invite
    #user = User.find_by(id: params[:id])
    @role = @user.roles.first
    message = I18n.t('users_controller.resending_invite')
    if @user.present?
      @user.invite! do |u|
        u.skip_invitation = true
      end
      @user.invitation_sent_at = Time.now.utc # mark invitation as delivered
      @user.invited_by_id = current_user.id
      InvitationMailer.invite_message(@user, @role, message).deliver_now
      redirect_to users_path, notice: I18n.t('users.resend_invite.resending_ok')
    else
      redirect_to users_path, notice: I18n.t('users.resend_invite.resending_failed')
    end
  end

  def change_language
    current_user.update_attribute('locale', params[:language])
    render json: 'success'.to_json
  end

  protected

  def user_params
    params.require(:user).permit(:is_active)
  end

  def can_edit?
    current_user.id != @user.try(:id)
  end

  def load_resource
    @user ||= User.find(params[:id])
  end

  def build_csv
    CSV.generate do |csv|
      csv << [I18n.t('users_controller.col_name'), I18n.t('users_controller.col_roles'), I18n.t('users_controller.col_last_activity')]
      Users::Presenter.index_table(@users, @navigation_context).map do |u|
        csv << [u[:name], u[:roles], u[:lastActivity]]
      end
    end
  end

  def apply_filters
    @users = @users.where("first_name LIKE ? OR last_name LIKE ? OR (email LIKE ? AND first_name IS NULL AND last_name IS NULL)", "%#{params["name"]}%", "%#{params["name"]}%", "%#{params["name"]}%") if params["name"].present?
    # There's no need to redo the join to roles_users because it was done by the scope "within"
    @users = @users.where("roles_users.role_id = ?", params["role"].to_i) if params["role"].present?
    @users = @users.where("last_sign_in_at > ? OR (last_sign_in_at IS NULL AND invitation_accepted_at IS NULL AND invitation_created_at > ?)", params["last_activity"], params["last_activity"]) if params["last_activity"].present?
    @users = @users.where("is_active = ?", params["is_active"].to_i) if params["is_active"].present?
  end

  def set_filter_params
    set_filter_from_params(FilterData::Users)
  end
end
