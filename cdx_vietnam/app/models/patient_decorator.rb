class Patient < ActiveRecord::Base

  validates :social_security_code, length: { in: 9..15 }

  def modify_entity_id_after_create
    self.entity_id = 'VPN' << self.id.to_s.rjust(6,'0')
    # this next bit is required here because the patient is set to be a phantom, if the entity id is null, when created.
    # if the name is not blank then this is probably not a phantom.
    self.is_phantom = false unless self.name.blank?
    self.save!
  end

end
