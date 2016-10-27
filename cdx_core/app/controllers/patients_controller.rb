# Patients controller
class PatientsController < ApplicationController
  before_filter :find_patient, only: %w(show edit update destroy)
  before_action :set_filter_params, only: [:index]

  def search
    @patients = check_access(Patient.where(is_phantom: false)
      .where(institution: @navigation_context.institution), READ_PATIENT).order(:name)
    @patients = @patients.where("name LIKE concat('%', ?, '%') OR entity_id LIKE concat('%', ?, '%')", params[:q], params[:q])
    @patients = @patients.page(1).per(10)

    builder = Jbuilder.new do |json|
      json.array! @patients do |patient|
        patient.as_json_card(json)
      end
    end

    render json: builder.attributes!
  end

  def index
    patients          = Patients::Finder.new(current_user, @navigation_context, params).filter_query
    @total            = patients.count
    order_by, offset  = perform_pagination('patients.name')
    @patients         = patients.order(order_by).limit(@page_size).offset(offset)
  end

  def show
    return unless authorize_resource(@patient, READ_PATIENT)

    @patient_json = Jbuilder.new { |json| @patient.as_json_card(json) }.attributes!
  end

  def new
    @patient = @navigation_context.institution.patients.new

    add_two_addresses

    authorize_resource(@navigation_context.institution, CREATE_INSTITUTION_PATIENT)
  end

  def create
    @institution = @navigation_context.institution
    return unless authorize_resource(@institution, CREATE_INSTITUTION_PATIENT)
    parse_date_of_birth
    @patient      = @institution.patients.new(patient_params)
    @patient.site = @navigation_context.site
    @patient.created_from_controller = true
    if validate_name_and_entity_id && @patient.save_and_audit("t{patients.create.audit_log}: #{@patient.name}")
      next_url = if params[:next_url].blank?
                   patient_path(@patient)
                 else
                   "#{params[:next_url]}#{params[:next_url].include?('?') ? '&' : '?'}patient_id=#{@patient.id}"
                 end

      redirect_to next_url, notice: I18n.t('patients.create.success')
    else
      render action: 'new'
    end
  end

  def edit
    return unless authorize_resource(@patient, UPDATE_PATIENT)
    add_two_addresses

    @can_delete = has_access?(@patient, DELETE_PATIENT)
  end

  def update
    return unless authorize_resource(@patient, UPDATE_PATIENT)
    parse_date_of_birth

    if name_is_present? && @patient.update_and_audit(patient_params, "#{@patient.name} t{patients.update.audit_log}")
      redirect_to patient_path(@patient), notice: I18n.t('patients.update.success')
    else
      render action: 'edit'
    end
  end

  def destroy
    return unless authorize_resource(@patient, DELETE_PATIENT)

    @patient.destroy_and_audit("#{@patient.name} t{patients.destroy.audit_log}")

    redirect_to patients_path, notice: I18n.t('patients.destroy.success')
  end

  protected

  def find_patient
    @patient = Patient.find(params[:id])
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

  def add_two_addresses
    (2 - @patient.addresses.size).times { @patient.addresses.build }
  end

  # Only patients from form need this validation. Phantom patients don't have entity_id
  def validate_name_and_entity_id
    @patient.valid?
    #@patient.errors.add(:entity_id, I18n.t('patients.create.no_entity')) if @patient.new_record? && !@patient.entity_id.present?
    @patient.errors.add(:name, I18n.t('patients.create.no_name'))      unless @patient.name.present?
    @patient.errors.empty?
  end

  def name_is_present?
    @patient.errors.add(:name, I18n.t('patients.create.no_name')) if params['patient'].key?('name') && params['patient']['name'].empty?
    @patient.errors.empty?
  end

  def parse_date_of_birth
    ['birth_date_on(2i)', 'birth_date_on(3i)'].each do |date_part|
      params['patient'][date_part] = '1' unless params['patient'][date_part].present?
    end
  end

  def set_filter_params
    set_filter_from_params(FilterData::Patients)
  end
end
