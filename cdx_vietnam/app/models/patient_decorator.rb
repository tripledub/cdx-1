class Patient < ActiveRecord::Base

  validates :social_security_code, length: { in: 9..15 }

  alias_method :core_patient_id_display, :patient_id_display

  def patient_id_display
    'VPN' << core_patient_id_display.to_s.rjust(6,'0')
  end

end
