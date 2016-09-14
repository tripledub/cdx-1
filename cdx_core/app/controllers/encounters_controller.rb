class EncountersController < ApplicationController
  before_filter :load_encounter, only: [:show, :edit, :destroy]
  before_filter :find_institution_and_patient,   only: [:new]

  def new_index
    return unless authorize_resource(Site, CREATE_SITE_ENCOUNTER).empty?
  end

  def new
    determine_referal

    @possible_assay_results = TestResult.possible_results_for_assay
    return unless authorize_resource(Site, CREATE_SITE_ENCOUNTER).empty?
  end

  def create
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).create
  end

  def sites
    sites = check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER)
    render json: s(sites.sort_by(&:name)).attributes!
  end

  def show
    return unless authorize_resource(@encounter, READ_ENCOUNTER)
    determine_referal
  end

  def edit
    if @encounter.has_dirty_diagnostic?
      @encounter.core_fields[Encounter::ASSAYS_FIELD] = @encounter.updated_diagnostic
      Encounters::Persistence.new(params, current_user, @localization_helper).prepare_blender_and_json(@encounter)
    end
    @possible_assay_results = TestResult.possible_results_for_assay
    return unless authorize_resource(@encounter, UPDATE_ENCOUNTER)
  end

  def destroy
    message = Encounters::Persistence.new(params, current_user, @localization_helper).destroy(@encounter)

    respond_to do |format|
      format.html { redirect_to encounters_path, notice: message }
      format.json { head :no_content }
    end
  end

  def update
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).update
  end

  def search_sample
    @institution = Finder::Institution.find_by_uuid(params[:institution_uuid])
    samples = scoped_samples\
      .joins("LEFT JOIN encounters ON encounters.id = samples.encounter_id")\
      .where("sample_identifiers.entity_id LIKE ?", "%#{params[:q]}%")\
      .where("samples.encounter_id IS NULL OR encounters.is_phantom = TRUE OR sample_identifiers.uuid IN (?)", (params[:sample_uuids] || "").split(','))
    render json: as_json_samples_search(samples).attributes!
  end

  def search_test
    @institution = Finder::Institution.find_by_uuid(params[:institution_uuid])
    test_results = scoped_test_results\
      .joins("LEFT JOIN encounters ON encounters.id = patient_results.encounter_id")\
      .where("patient_results.encounter_id IS NULL OR encounters.is_phantom = TRUE")\
      .where("patient_results.test_id LIKE ?", "%#{params[:q]}%")
    render json: as_json_test_results_search(test_results).attributes!
  end

  def add_sample
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).add_sample
  end

  def add_test
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).add_test
  end

  def merge_samples
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).merge_samples
  end

  def new_sample
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).new_sample
  end

  def add_sample_manually
    render json: Encounters::Persistence.new(params, current_user, @localization_helper).add_sample_manually
  end

  private

  def determine_referal
    @show_edit_encounter   = true
    @show_cancel_encounter = false
    @return_path_encounter = nil
    @return_path_encounter = test_orders_path if params['test_order_page_mode'] != nil

    if request.referer
      referer       = URI(request.referer).path
      if (referer =~ /\/patients\/\d/) || (params['test_order_page_mode'] == 'cancel')
        @show_edit_encounter   = false
        @show_cancel_encounter = true if @encounter && (Encounter.statuses[@encounter.status] == Encounter.statuses["pending"])
        if @encounter && @encounter.patient
          @return_path_encounter = patient_path(@encounter.patient)
        else
          @return_path_encounter = referer
        end
      end
    end
  end

  def load_encounter
    @encounter = Encounter.where('uuid = :id', params).first ||
                 Encounter.where('id = :id', params).first
    return head(:not_found) unless @encounter.present? && (@encounter.id == params[:id].to_i || @encounter.uuid == params[:id])

    @encounter.new_samples = []
    Encounters::Persistence.new(params, current_user, @localization_helper).prepare_blender_and_json(@encounter)

  end

  def scoped_test_results
    authorize_resource(TestResult, QUERY_TEST).where(institution: @institution)
  end

  def add_test_result_by_uuid(uuid)
    test_result         = scoped_test_results.find_by!(uuid: uuid)
    test_result_blender = @blender.load(test_result)
    @blender.merge_parent(test_result_blender, @encounter_blender)
    test_result_blender
  end

   def as_json_samples_search(samples)
     Jbuilder.new do |json|
       json.array! samples do |sample|
         as_json_sample(json, sample)
       end
     end
   end

  def as_json_site_list(sites)
    Jbuilder.new do |json|
      json.total_count sites.size
      json.sites sites do |site|
        as_json_site(json, site)
      end
    end
  end

  def as_json_test_results_search(test_results)
    Jbuilder.new do |json|
      json.array! test_results do |test|
        test.as_json(json, @localization_helper)
      end
    end
  end

  def find_institution_and_patient
    @institution = @navigation_context.institution

    redirect_to test_orders_path, notice: I18n.t('encounters.new.no_patient') unless @patient = Finder::Patient.find_by_institution(@institution, current_user).where(id: params[:patient_id]).first
  end
end
