# sample identifiers
class SampleIdentifier < ActiveRecord::Base
  include AutoUUID

  belongs_to :sample, inverse_of: :sample_identifiers
  belongs_to :site, -> { with_deleted }, inverse_of: :sample_identifiers
  has_many   :test_results, inverse_of: :sample_identifier, dependent: :restrict_with_error
  has_many   :patient_results

  validates_presence_of :sample
  validate :site_and_uniqueness_of_entity_id_in_site_time_window

  acts_as_paranoid

  def phantom?
    entity_id.nil?
  end

  def not_phantom?
    !phantom?
  end

  private

  def site_and_uniqueness_of_entity_id_in_site_time_window
    return unless sample

    # SampleIdentifiers might be created without user friendly id
    # i.e.: allow blank entity_id
    return if entity_id.blank?

    unless site
      errors.add(:site, I18n.t('models.sample_identifier.cant_be_blank'))
      return
    end

    sample_ident_date = created_at || Time.now.utc

    if site.sample_identifiers_on_time(sample_ident_date).where(entity_id: entity_id).where.not(id: id).exists?
      errors.add(:entity_id, "#{entity_id} #{I18n.t('models.sample_identifier.is_already')} #{site.time_window(sample_ident_date)}")
    end
  end
end
