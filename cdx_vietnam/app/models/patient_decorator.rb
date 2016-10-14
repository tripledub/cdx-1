class Patient < ActiveRecord::Base

  validates :social_security_code, length: { in: 9..15 }

  def display_patient_id
    'VPN' << id.to_s.rjust(6,'0')
  end

  def self.gender_options
    [
      ['male', I18n.t('select.patient.gender_options.male')],
      ['female', I18n.t('select.patient.gender_options.female')]
    ]
  end
end
