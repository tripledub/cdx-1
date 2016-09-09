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
    perform_encounter_action 'creating encounter' do
      prepare_encounter_from_json
      create_requested_tests
      create_new_samples
      @encounter.user = current_user
      @blender.save_and_index!
      @encounter.updated_diagnostic_timestamp!
      store_create_encounter_audit_log
    end
  end

  def sites
    sites = check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER)
    render json: as_json_site_list(sites.sort_by(&:name)).attributes!
  end

  def show
    return unless authorize_resource(@encounter, READ_ENCOUNTER)
    determine_referal
  end

  def edit
    if @encounter.has_dirty_diagnostic?
      @encounter.core_fields[Encounter::ASSAYS_FIELD] = @encounter.updated_diagnostic
      prepare_blender_and_json
    end
    @possible_assay_results = TestResult.possible_results_for_assay
    return unless authorize_resource(@encounter, UPDATE_ENCOUNTER)
  end

  def destroy
    if @encounter.status == 'pending'
      # note: Cannot delete record because dependent samples exist, so just set deleted_at
      @encounter.update(deleted_at: Time.now)
      begin
         Cdx::Api.client.delete index: Cdx::Api.index_name, type: 'encounter', id: @encounter.uuid
         Audit::EncounterAuditor.new(@encounter, current_user.id).log_action(I18n.t('encounters.destroy.cancelled'), I18n.t('encounters.destroy.log_action', uuid: @encounter.uuid), @encounter)
         message = I18n.t('encounters.destroy.success')
      rescue => ex
        Rails.logger.error ex.message
      end
    else
      message = I18n.t('encounters.destroy.not_allowed')
    end

    respond_to do |format|
      format.html { redirect_to encounters_path, notice: message }
      format.json { head :no_content }
    end
  end

  def update
    perform_encounter_action "updating encounter" do
      prepare_encounter_from_json
      return unless authorize_resource(@encounter, UPDATE_ENCOUNTER)
      raise "encounter.id does not match" if params[:id].to_i != @encounter.id
      create_new_samples
      @blender.save_and_index!
      @encounter.updated_diagnostic_timestamp!
    end
  end

  def search_sample
    @institution = institution_by_uuid(params[:institution_uuid])
    samples = scoped_samples\
      .joins("LEFT JOIN encounters ON encounters.id = samples.encounter_id")\
      .where("sample_identifiers.entity_id LIKE ?", "%#{params[:q]}%")\
      .where("samples.encounter_id IS NULL OR encounters.is_phantom = TRUE OR sample_identifiers.uuid IN (?)", (params[:sample_uuids] || "").split(','))
    render json: as_json_samples_search(samples).attributes!
  end

  def search_test
    @institution = institution_by_uuid(params[:institution_uuid])
    test_results = scoped_test_results\
      .joins("LEFT JOIN encounters ON encounters.id = patient_results.encounter_id")\
      .where("patient_results.encounter_id IS NULL OR encounters.is_phantom = TRUE")\
      .where("patient_results.test_id LIKE ?", "%#{params[:q]}%")
    render json: as_json_test_results_search(test_results).attributes!
  end

  def add_sample
    perform_encounter_action "adding sample" do
      prepare_encounter_from_json
      add_sample_by_uuid params[:sample_uuid]
      recalculate_diagnostic
    end
  end

  def add_test
    perform_encounter_action "adding test result" do
      prepare_encounter_from_json
      add_test_result_by_uuid params[:test_uuid]
      recalculate_diagnostic
    end
  end

  def merge_samples
    perform_encounter_action "unifying samples" do
      prepare_encounter_from_json
      merge_samples_by_uuid params[:sample_uuids]
      recalculate_diagnostic
    end
  end

  def new_sample
    perform_encounter_action "creating new sample" do
      prepare_encounter_from_json
      added_sample      = new_sample_for_site
      @extended_respone = { sample: added_sample }
    end
  end

  def add_sample_manually
    perform_encounter_action "adding manual sample" do
      prepare_encounter_from_json
      sample = { entity_id: params[:entity_id], lab_sample_id: params[:lab_sample_id]}
      if validate_manual_sample_non_existant(sample)
        @encounter.new_samples << sample
        @extended_respone = { sample: sample }
      else
        render json: {
          message: I18n.t('encounters_controller.sample_id_used'),
          status: 'error'
        }, status: 200 and return
      end
    end
  end

  private

  def store_create_encounter_audit_log
    Audit::EncounterAuditor.new(@encounter, current_user.id).log_changes(I18n.t('encounters_controller.test_order_created'), "#{@encounter.id}", @encounter)
    @encounter.requested_tests.each do |test|
      Audit::EncounterTestAuditor.new(@encounter, current_user.id).log_changes("#{I18n.t('encounters_controller.new')} #{test.name} #{I18n.t('encounters_controller.test_created')}", "#{I18n.t('encounters_controller.test')} #{test.name} #{I18n.t('encounters_controller.created_for')} #{@encounter.uuid}", @encounter, test)
    end
  end

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

  def create_requested_tests
    encounter_param = @encounter_param = JSON.parse(params[:encounter])
    tests_requested = encounter_param['tests_requested']

    if tests_requested.present?
      tests_requested.split('|').each do |name|
        @encounter.requested_tests.build(name: name, status: RequestedTest.statuses["pending"])
      end
   end
  end

  def perform_encounter_action(action)
    @extended_respone = {}
    begin
      yield
    rescue Blender::MergeNonPhantomError => e
      render json: { status: :error, message: I18n.t('encounters.perform_encounter_action.merge', entity_type: e.entity_type.model_name.singular), encounter: as_json_edit.attributes! }, status: :unprocessable_entity
    rescue => e
      Rails.logger.error(e.backtrace.unshift(e.message).join("\n"))
      render json: { status: :error, message: I18n.t('encounters.perform_encounter_action.error', action_name: action, class_name: e.class), encounter: as_json_edit.attributes! }, status: :unprocessable_entity
    else
      render json: { status: :ok, encounter: as_json_edit.attributes! }.merge(@extended_respone)
    end
  end

  def load_encounter
    @encounter = Encounter.where('uuid = :id', params).first ||
                 Encounter.where('id = :id', params).first
    return head(:not_found) unless @encounter.present? && (@encounter.id == params[:id].to_i || @encounter.uuid == params[:id])

    @encounter.new_samples = []
    @institution = @encounter.institution
    prepare_blender_and_json
  end

  def prepare_blender_and_json
    @blender = Blender.new(@institution)
    @encounter_blender = @blender.load(@encounter)
    @encounter_as_json = as_json_edit.attributes!
  end

  def institution_by_uuid(uuid)
    check_access(Institution, READ_INSTITUTION).where(uuid: uuid).first
  end

  def site_by_uuid(institution, uuid)
    check_access(institution.sites, CREATE_SITE_ENCOUNTER).where(uuid: uuid).first
  end

  def prepare_encounter_from_json
    encounter_param        = @encounter_param = JSON.parse(params[:encounter])
    @encounter             = encounter_param['id'] ? Encounter.find(encounter_param['id']) : Encounter.new
    @encounter.new_samples = []
    @encounter.is_phantom  = false

    if @encounter.new_record?
      @institution                 = institution_by_uuid(encounter_param['institution']['uuid'])
      @encounter.institution       = @institution
      @encounter.site              = site_by_uuid(@institution, encounter_param['site']['uuid'])
      @encounter.performing_site   = site_by_uuid(@institution, encounter_param['performing_site']['uuid']) if encounter_param['performing_site'] !=nil
      @encounter.exam_reason       = encounter_param['exam_reason']
      @encounter.tests_requested   = encounter_param['tests_requested']
      @encounter.coll_sample_type  = encounter_param['coll_sample_type']
      @encounter.coll_sample_other = encounter_param['coll_sample_other']
      @encounter.culture_format    = encounter_param['culture_format'] if encounter_param['culture_format'].present?
      @encounter.diag_comment      = encounter_param['diag_comment']
      @encounter.treatment_weeks   = encounter_param['treatment_weeks']
      @encounter.testdue_date      = encounter_param['testdue_date']
      @encounter.testing_for       = encounter_param['testing_for']
      @encounter.presumptive_rr    = encounter_param['presumptive_rr']
    else
      @institution                 = @encounter.institution
    end

    @blender = Blender.new(@institution)
    @encounter_blender = @blender.load(@encounter)

    set_patient_by_id get_patient_id_from_params(encounter_param)

    encounter_param['samples'].each do |sample_param|
      add_sample_by_uuids sample_param['uuids']
    end

    encounter_param['new_samples'].each do |new_sample_param|
      @encounter.new_samples << { entity_id: new_sample_param['entity_id'], lab_sample_id: new_sample_param['lab_sample_id'] }
    end

    encounter_param['test_results'].each do |test_param|
      add_test_result_by_uuid test_param['uuid']
    end

    @encounter_blender.merge_attributes(
      'core_fields' => { Encounter::ASSAYS_FIELD => encounter_param['assays'] },
      'plain_sensitive_data' => { Encounter::OBSERVATIONS_FIELD => encounter_param['observations'] }
    )
  end

  def create_new_samples
    @encounter.new_samples.each do |new_sample|
      add_new_sample_by_entity_id new_sample
    end
    @encounter.new_samples = []
  end

  def scoped_samples
    samples_in_encounter = "samples.encounter_id = #{@encounter.id} OR " if @encounter.try(:persisted?)
    # TODO this logic is not enough to grab an empty sample from one encounter and move it to another. but is ok for CRUD experience

    Sample.where("#{samples_in_encounter} samples.id in (#{authorize_resource(TestResult, QUERY_TEST).joins(:sample_identifier).select('sample_identifiers.sample_id').to_sql})")
              .where(institution: @institution)
              .joins(:sample_identifiers)
  end

  def new_sample_for_site
    sample = { entity_id: @encounter.site.generate_next_sample_entity_id! }
    @encounter.new_samples << sample
    sample
  end

  def add_sample_by_uuid(uuid)
    sample = scoped_samples.find_by!("sample_identifiers.uuid" => uuid)
    sample_blender = @blender.load(sample)
    @blender.merge_parent(sample_blender, @encounter_blender)
    sample_blender
  end

  def add_sample_by_uuids(uuids)
    sample_blender = merge_samples_by_uuid(uuids)
    @blender.merge_parent(sample_blender, @encounter_blender)
    sample_blender
  end

  def set_patient_by_id(id)
    return unless id
    patient         = scoped_patients.find(id)
    patient_blender = @blender.load(patient)
    @blender.merge_parent(@encounter_blender, patient_blender)
    patient_blender
  end

  def add_new_sample_by_entity_id(sample_identifier)
    sample = Sample.new(institution: @encounter.institution)
    sample.sample_identifiers.build(
      site: @encounter.site,
      entity_id: sample_identifier[:entity_id],
      lab_sample_id: sample_identifier[:lab_sample_id]
    )

    sample_blender = @blender.load(sample)
    @blender.merge_parent(sample_blender, @encounter_blender)
    sample_blender
  end

  def merge_samples_by_uuid(uuids)
    samples = scoped_samples.where("sample_identifiers.uuid" => uuids).to_a
    raise ActiveRecord::RecordNotFound if samples.empty?
    target, *to_merge = samples.map{|s| @blender.load(s)}
    @blender.merge_blenders(target, to_merge)
  end

  def scoped_test_results
    authorize_resource(TestResult, QUERY_TEST).where(institution: @institution)
  end

  def scoped_patients
    authorize_resource(Patient, READ_PATIENT).where(institution: @institution)
  end

  def add_test_result_by_uuid(uuid)
    test_result         = scoped_test_results.find_by!(uuid: uuid)
    test_result_blender = @blender.load(test_result)
    @blender.merge_parent(test_result_blender, @encounter_blender)
    test_result_blender
  end

  def recalculate_diagnostic
    previous_tests_uuids = @encounter_param['test_results'].map{|t| t['uuid']}
    assays_to_merge      = @blender.test_results\
      .reject{|tr| (tr.uuids & previous_tests_uuids).any?}\
      .map{|tr| tr.core_fields[TestResult::ASSAYS_FIELD]}

    diagnostic_assays = assays_to_merge.inject(@encounter_param['assays']) do |merged, to_merge|
      Encounter.merge_assays(merged, to_merge)
    end

    @encounter_blender.merge_attributes('core_fields' => {
      Encounter::ASSAYS_FIELD => diagnostic_assays
    })
  end

  def validate_manual_sample_non_existant(sample)
    matching_id = Sample.joins(:sample_identifiers)\
      .where("sample_identifiers.entity_id = ?", "#{sample[:entity_id]}")
    matching_id = matching_id.joins("LEFT JOIN encounters ON encounters.id = samples.encounter_id").where(patient_id: @encounter.patient_id) if @encounter.patient_id
    matching_id.count == 0
  end

  def as_json_edit
    Jbuilder.new do |json|
      json.(@encounter, :id)
      json.(@encounter, :uuid)
      json.(@encounter, :batch_id)
      json.(@encounter, :user)
      json.(@encounter, :exam_reason)
      json.(@encounter, :tests_requested)
      json.(@encounter, :coll_sample_type)
      json.(@encounter, :coll_sample_other)
      json.(@encounter, :diag_comment)
      json.(@encounter, :treatment_weeks)
      json.(@encounter, :status)
      json.(@encounter, :testdue_date)
      json.(@encounter, :testing_for)
      json.culture_format Extras::Select.find(Encounter.culture_format_options, @encounter.culture_format)
      json.has_dirty_diagnostic @encounter.has_dirty_diagnostic?
      json.assays (@encounter_blender.core_fields[Encounter::ASSAYS_FIELD] || [])
      json.observations @encounter_blender.plain_sensitive_data[Encounter::OBSERVATIONS_FIELD]
      json.institution do
        as_json_institution(json, @institution)
      end

      json.site do
        as_json_site(json, @encounter.site)
      end

      if @encounter.performing_site
        json.performing_site do
          as_json_site(json, @encounter.performing_site)
        end
      end

      json.patient do
        if @encounter_blender.patient.blank?
          json.nil!
        else
          @encounter_blender.patient.preview.as_json_card(json)
        end
      end

      json.samples @encounter_blender.samples.uniq do |sample|
        as_json_sample(json, sample)
      end

      json.(@encounter, :new_samples)
      @localization_helper.devices_by_uuid = @encounter_blender.test_results.map{|tr| tr.single_entity.device}.uniq.index_by &:uuid
      json.test_results @encounter_blender.test_results.uniq do |test_result|
        test_result.single_entity.as_json(json, @localization_helper)
      end
    end
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

  def as_json_sample(json, sample)
    json.(sample, :uuids, :entity_ids, :lab_sample_ids)
    json.uuid sample.uuids[0]
  end

  def as_json_test_results_search(test_results)
    Jbuilder.new do |json|
      json.array! test_results do |test|
        test.as_json(json, @localization_helper)
      end
    end
  end

  def as_json_institution(json, institution)
    json.(institution, :uuid, :name)
  end

  def as_json_site(json, site)
    json.(site, :uuid, :name, :allows_manual_entry)
  end

  def find_institution_and_patient
    @institution = @navigation_context.institution

    redirect_to test_orders_path, notice: I18n.t('encounters.new.no_patient') unless @patient = scoped_patients.where(id: params[:patient_id]).first
  end

  def get_patient_id_from_params(encounter_param)
    return unless encounter_param['patient'] || encounter_param['patient_id']

    encounter_param['patient'].present? ? encounter_param['patient']['id'] : encounter_param['patient_id']
  end
end
