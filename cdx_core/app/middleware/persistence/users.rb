class Persistence::Users
  attr_reader :status_message

  def initialize(current_user)
    @status_message = ''
    @current_user   = current_user
  end

  def add_and_invite(new_users, message, role)
    new_users.each do |email|
      create(email, message, role) if email.strip.length > 0
    end
  end

  protected

  def create(email, message, role)
    user = User.find_by(email: email)
    if user.present?
      @status_message << I18n.t('users.persistence.create.user_already_present', email: email)
    else
      user = User.new(email: email)
      invite_user(user, message, role) unless user.persisted?
      add_role(user, role)
      ComputedPolicy.update_user(user)
    end
  end

  def invite_user(user, message, role)
    user.invite! do |u|
      u.skip_invitation = true
    end
    user.invitation_sent_at = Time.now.utc
    user.invited_by_id      = @current_user.id
    InvitationMailer.delay.invite_message(user, role, message)
  end

  def add_role(user, role)
    add_default_institution_read(user)
    user.roles << role unless user.roles.include?(role)
  end

  def add_default_institution_read(user)
    return unless institution = find_from_user_context
    role = Role.find_by_name("Institution #{institution.name} Reader")
    user.roles << role unless user.roles.include?(role)
  end

  def find_from_user_context
    institution = Institution.find_by_uuid(@current_user.last_navigation_context)
    if !institution
      site        = Site.find_by_uuid(@current_user.last_navigation_context)
      institution = site.institution if site
    end

    institution
  end
end
