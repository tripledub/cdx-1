class PatientsController

  def validate_name_and_entity_id
    @patient.valid?
    @patient.errors.add(:name, I18n.t('patients.create.no_entity')) unless @patient.name.present?
    @patient.errors.empty?
  end

end