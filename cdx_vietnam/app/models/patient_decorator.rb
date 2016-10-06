class Patient < ActiveRecord::Base

  validates :social_security_code, length: { in: 9..15 }

  def display_patient_id
    'VPN' << self.id.to_s.rjust(6,'0')
  end

end
