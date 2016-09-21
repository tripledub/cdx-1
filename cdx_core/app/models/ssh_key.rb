class SshKey < ActiveRecord::Base
  belongs_to :device

  validates_uniqueness_of :device_id
  validates_presence_of :public_key, :device
  validate :validate_public_key

  before_save :delete_other_ssh_keys_with_same_public_key

  def validate_public_key
    to_client.validate! unless public_key.blank?
  rescue
    errors.add(:public_key, "#{I18n.t('models.ssh_key.key')} #{public_key.truncate(10)} #{I18n.t('models.ssh_key.is_invalid')}")
  end

  def to_client
    SyncHelpers.to_client(device, public_key)
  end

  def self.regenerate_authorized_keys!
    SyncHelpers.regenerate_authorized_keys!(clients)
  end

  def self.clients
    all.map(&:to_client)
  end

  private

  def delete_other_ssh_keys_with_same_public_key
    SshKey.where(public_key: public_key).delete_all
  end
end
