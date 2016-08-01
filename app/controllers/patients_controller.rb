class PatientsController < ApplicationController
  def search
    @patients = check_access(Patient.where(is_phantom: false).where(institution: @navigation_context.institution), READ_PATIENT).order(:name)
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
    @can_create = has_access?(@navigation_context.institution, CREATE_INSTITUTION_PATIENT)
    @patients = check_access(Patient.where(is_phantom: false).where(institution: @navigation_context.institution), READ_PATIENT)

    @patients = @patients.within(@navigation_context.entity, @navigation_context.exclude_subsites)

    params[:name] = session[:patients_filter_name] if params[:name].nil?
    session[:patients_filter_name] = params[:name]
    
    params[:entity_id] = session[:patients_filter_entity_id] if params[:entity_id].nil?
    session[:patients_filter_entity_id] = params[:entity_id]

    params[:location] = session[:patients_filter_location] if params[:location].nil?
    session[:patients_filter_location] = params[:location]

    params[:last_encounter] = session[:patients_filter_lastencounter] if params[:last_encounter].nil?
    session[:patients_filter_lastencounter] = params[:last_encounter]

    params[:page] = session[:patients_filter_page] if params[:page].nil?
    session[:patients_filter_page] = params[:page]

    params[:page_size] = session[:patients_filter_pagesize] if params[:page_size].nil?
    session[:patients_filter_pagesize] = params[:page_size] 


    @patients = @patients.where("name LIKE concat('%', ?, '%')", params[:name]) unless params[:name].blank?
    @patients = @patients.where("entity_id LIKE concat('%', ?, '%')", params[:entity_id]) unless params[:entity_id].blank?
    # location_geoid is hierarchical so a prefix search works
    @patients = @patients.where("location_geoid LIKE concat(?, '%')", params[:location]) unless params[:location].blank?
    @patients = @patients.where(id: Encounter.select(:patient_id).where("encounters.start_time > ?", params["last_encounter"])) if params["last_encounter"].present?

    @date_options = Extras::Dates::Filters.date_options_for_filter

    @total            = @patients.count
    order_by, offset  = perform_pagination('patients.name')
    @patients         = @patients.order(order_by).limit(@page_size).offset(offset)
  end

  def show
    @patient = Patient.find(params[:id])
    return unless authorize_resource(@patient, READ_PATIENT)

    @patient_json = Jbuilder.new { |json| @patient.as_json_card(json) }.attributes!
  end

  def new
    @patient = @navigation_context.institution.patients.new

    add_two_addresses

    prepare_for_institution_and_authorize(@patient, CREATE_INSTITUTION_PATIENT)
  end

  def create
    @institution  = @navigation_context.institution
    return unless authorize_resource(@institution, CREATE_INSTITUTION_PATIENT)
    parse_date_of_birth
    @patient      = @institution.patients.new(patient_params)
    @patient.site = @navigation_context.site

    if validate_name_and_entity_id && @patient.save_and_audit(current_user, "New patient #{@patient.name} added")
      next_url = if params[:next_url].blank?
        patient_path(@patient)
      else
        "#{params[:next_url]}#{params[:next_url].include?('?') ? '&' : '?'}patient_id=#{@patient.id}"
      end

      redirect_to next_url, notice: 'Patient was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @patient  = Patient.find(params[:id])
    return unless authorize_resource(@patient, UPDATE_PATIENT)
    add_two_addresses

    @can_delete = has_access?(@patient, DELETE_PATIENT)
  end

  def update
    @patient  = Patient.find(params[:id])
    return unless authorize_resource(@patient, UPDATE_PATIENT)
    parse_date_of_birth

    if name_is_present? && @patient.update_and_audit(patient_params, current_user, "#{@patient.name} patient details have been updated")
      redirect_to patient_path(@patient), notice: 'Patient was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @patient = Patient.find(params[:id])
    return unless authorize_resource(@patient, DELETE_PATIENT)

    @patient.destroy

    redirect_to patients_path, notice: 'Patient was successfully deleted.'
  end

  private

  def patient_params
    params.require(:patient).permit(
      :name, :entity_id, :gender, :nickname, :birth_date_on, :lat, :lng, :location_geoid, :address, :email, :phone, :city, :state, :zip_code,
      addresses_attributes: [ :id, :address, :city, :state, :zip_code ]
    )
  end

  def add_two_addresses
    (2 - @patient.addresses.size).times { @patient.addresses.build }
  end

  def validate_name_and_entity_id
    #Only patients from form need this validation. Phantom patientes don't have name or entity_id
    @patient.valid?
    @patient.errors.add(:entity_id, I18n.t('patients.create.no_entity')) if @patient.new_record? && !@patient.entity_id.present?
    @patient.errors.add(:name, I18n.t('patients.create.no_entity'))      unless @patient.name.present?
    @patient.errors.empty?
  end

  def name_is_present?
    @patient.valid?
    @patient.errors.add(:name, I18n.t('patients.create.no_entity')) if params['patient'].key?('name') && params['patient']['name'].empty?
    @patient.errors.empty?
  end

  def parse_date_of_birth
    ['birth_date_on(2i)', 'birth_date_on(3i)'].each do |date_part|
      params['patient'][date_part] = '1' unless params['patient'][date_part].present?
    end
  end
end
