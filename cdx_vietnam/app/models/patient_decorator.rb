# Vietnam specific logic for patients
class Patient < ActiveRecord::Base
  validates :social_security_code, length: { in: 9..15, message: :cmnd_validation },
                                   unless: proc { |patient| patient.skip_ssc_validation },
                                   allow_blank: true

  def display_patient_id
    'VPN' << id.to_s.rjust(6, '0')
  end

  def self.gender_options
    [
      ['male', I18n.t('select.patient.gender_options.male')],
      ['female', I18n.t('select.patient.gender_options.female')]
    ]
  end

  def self.nationality_options
    [
      ['native', I18n.t('select.patient.nationality_option.native')],
      ['foreign', I18n.t('select.patient.nationality_option.foreign')]
    ]
  end

  def vitimes_id
    custom_fields['vitimes_id']
  end

  def vitimes_id=(value)
    custom_fields['vitimes_id'] = value
  end
end
