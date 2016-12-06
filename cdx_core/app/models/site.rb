# Sites model.  Sites can be nested in a tree structure.
class Site < ActiveRecord::Base
  include AutoUUID
  include Resource
  extend ActsAsTree::TreeWalker

  acts_as_paranoid
  acts_as_tree order: 'name'

  belongs_to :institution
  has_one :user, through: :institution
  has_many :devices, dependent: :restrict_with_exception
  has_many :test_results
  has_many :sample_identifiers
  has_many :samples, through: :sample_identifiers
  has_many :roles, dependent: :destroy
  has_many :notification_sites, class_name: 'Notification::Site'
  has_many :notifications,      through: :notification_sites

  validates_presence_of :institution
  validates_presence_of :name
  validates_presence_of :time_zone
  validate :same_institution_as_parent

  after_create :compute_prefix
  after_create :create_predefined_roles
  after_update :update_predefined_roles, if: :name_changed?

  scope :within, -> (institution_or_site, exclude_subsites = false) {
    if institution_or_site.is_a?(Institution) && exclude_subsites
      where(institution: institution_or_site, parent: nil)
    elsif institution_or_site.is_a?(Institution)
      where(institution: institution_or_site)
    elsif institution_or_site.is_a?(Site) && exclude_subsites
      where(parent: institution_or_site)
    else
      where("prefix LIKE concat(?, '%')", institution_or_site.prefix)
    end
  }

  def self.filter_by_owner(user, check_conditions)
    if check_conditions
      joins(:institution).where(institutions: { user_id: user.id })
    else
      self
    end
  end

  def filter_by_owner(user, _check_conditions)
    institution.user_id == user.id ? self : nil
  end

  def self.filter_by_query(query)
    if institution = query['institution']
      where(institution_id: institution)
    else
      self
    end
  end

  def filter_by_query(query)
    if institution = query['institution']
      if institution_id == institution.to_i
        self
      else
        nil
      end
    else
      self
    end
  end

  def path
    prefix.split('.')
  end

  def to_s
    name
  end

  def self.prefix(id)
    Site.unscoped.find(id).prefix
  end

  def generate_next_sample_entity_id!
    with_lock do # if with_lock is removed, serialization will be lost (ref 46ccfd) fix #712
      current_time = Time.now.utc
      last_in_time_window = last_sample_identifier_entity_id
      date = last_sample_identifier_date || current_time
      next_window_start = time_window(date).end + 1.day
      last_in_time_window = nil if current_time >= next_window_start
      next_entity_id = (last_in_time_window || '99999').succ

      while sample_identifiers_on_time(current_time).exists?(entity_id: next_entity_id)
        next_entity_id = next_entity_id.succ
      end

      update_attribute(:last_sample_identifier_entity_id, next_entity_id)
      update_attribute(:last_sample_identifier_date, current_time)

      next_entity_id
    end
  end

  def time_window(date)
    start_date = case sample_id_reset_policy
                 when 'weekly' then date.beginning_of_week
                 when 'monthly' then date.beginning_of_month
                 when 'yearly' then date.beginning_of_year
                 else raise "#{sample_id_reset_policy} #{I18n.t('models.site.reset_start_date')}"
                 end

    end_date = case sample_id_reset_policy
               when 'weekly' then date.end_of_week
               when 'monthly' then date.end_of_month
               when 'yearly' then date.end_of_year
               else raise "#{sample_id_reset_policy} #{I18n.t('models.site.reset_end_date')}"
               end

    start_date..end_date
  end

  def sample_identifiers_on_time(date)
    sample_identifiers.where(created_at: time_window(date))
  end

  private

  def compute_prefix
    self.prefix = parent ? "#{parent.prefix}.#{uuid}" : uuid
    save!
  end

  def same_institution_as_parent
    errors.add(:institution, I18n.t('models.site.must_match')) if parent && parent.institution != institution
  end

  def create_predefined_roles
    roles = Policy.predefined_site_roles(self)
    roles.each do |role|
      role.institution = institution
      role.site = self
      role.save!
    end
  end

  def update_predefined_roles
    existing_roles = roles.predefined.all
    new_roles = Policy.predefined_site_roles(self)
    existing_roles.each do |existing_role|
      new_role = new_roles.find { |new_role| new_role.key == existing_role.key }
      next unless new_role

      existing_role.name = new_role.name
      existing_role.save!
    end
  end
end
