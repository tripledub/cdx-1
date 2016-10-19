# Vietnam specific code for patients controller
class PatientsController
  def validate_name_and_entity_id
    @patient.valid?
    @patient.errors.add(:name, I18n.t('patients.create.no_entity')) unless @patient.name.present?
    @patient.errors.empty?
  end

  def patient_params
    params.require(:patient).permit(
      :name,
      :entity_id,
      :gender,
      :nickname,
      :medical_insurance_num,
      :social_security_code,
      :external_id,
      :external_system_id,
      :vitimes_id,
      :skip_ssc_validation,
      :external_patient_system,
      :birth_date_on,
      :address,
      :email,
      :phone,
      :city,
      :state,
      :zip_code,
      :created_from_controller,
      addresses_attributes: [:id, :address, :city, :state, :country, :zip_code]
    )
  end
end
