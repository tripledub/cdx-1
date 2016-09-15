module Encounters
  class Persistence
    attr_reader :params, :current_user, :localization_helper

    def initialize(params, current_user, localization_helper)
      @params = params
      @current_user = current_user
      @localization_helper = localization_helper
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

    def update
      perform_encounter_action "updating encounter" do
        prepare_encounter_from_json
        return unless Policy.authorize(UPDATE_ENCOUNTER, @encounter, current_user)
        raise "encounter.id does not match" if params[:id].to_i != @encounter.id
        create_new_samples
        @blender.save_and_index!
        @encounter.updated_diagnostic_timestamp!
      end
    end

    def destroy(encounter)
      @encounter = encounter
      if @encounter.status == 'new'
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
          return {
            message: I18n.t('encounters_controller.sample_id_used'),
            status: 'error'
          }, :unprocessable_entity
        end
      end
    end

    def search_test(test_id)
      institution = Finder::Institution.find_by_uuid(params[:institution_uuid], current_user)
      test_results = Finder::TestResults.find_by_institution(institution, current_user)
        .joins("LEFT JOIN encounters ON encounters.id = patient_results.encounter_id")
        .where("patient_results.encounter_id IS NULL OR encounters.is_phantom = TRUE")
        .where("patient_results.test_id LIKE ?", "%#{test_id}%")
      Finder::TestResults.as_json_list(test_results, @localization_helper).attributes!
    end

    def prepare_blender_and_json(encounter)
      @encounter = encounter
      @blender = Blender.new(encounter.institution)
      @encounter_blender = @blender.load(encounter)
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
          Finder::Institution.as_json(json, @encounter.institution)
        end

        json.site do
          Finder::Site.as_json(json, @encounter.site)
        end

        if @encounter.performing_site
          json.performing_site do
            Finder::Site.as_json(json, @encounter.performing_site)
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
          Finder::Sample.as_json(json, sample)
        end

        json.(@encounter, :new_samples)
        localization_helper.devices_by_uuid = @encounter_blender.test_results.map{|tr| tr.single_entity.device}.uniq.index_by &:uuid
        json.test_results @encounter_blender.test_results.uniq do |test_result|
          test_result.single_entity.as_json(json, localization_helper)
        end
      end
    end

    protected

    def perform_encounter_action(action)
      @extended_respone = {}
      begin
        yield
      rescue Blender::MergeNonPhantomError => e
        return { status: :error, message: I18n.t('encounters.perform_encounter_action.merge', entity_type: e.entity_type.model_name.singular), encounter: as_json_edit.attributes! }, :unprocessable_entity
      rescue => e
        Rails.logger.error(e.backtrace.unshift(e.message).join("\n"))
        return { status: :error, message: I18n.t('encounters.perform_encounter_action.error', action_name: action, class_name: e.class), encounter: as_json_edit.attributes! }, :unprocessable_entity
      else
        return { status: :ok, encounter: as_json_edit.attributes! }.merge(@extended_respone), :ok
      end
    end

    def prepare_encounter_from_json
      encounter_param        = @encounter_param = JSON.parse(params[:encounter])
      @encounter             = encounter_param['id'] ? Encounter.find(encounter_param['id']) : Encounter.new
      @encounter.new_samples = []
      @encounter.is_phantom  = false

      if @encounter.new_record?
        @institution                 = Finder::Institution.find_by_uuid(encounter_param['institution']['uuid'], current_user)
        @encounter.institution       = @institution
        @encounter.site              = Finder::Site.find_by_uuid(encounter_param['site']['uuid'], current_user, @institution)
        @encounter.performing_site   = Finder::Site.find_by_uuid(encounter_param['performing_site']['uuid'], current_user, @institution) if encounter_param['performing_site'] !=nil
        @encounter.status            = 'new'
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
        @encounter.test_batch        = ::TestBatch.new
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

    def get_patient_id_from_params(encounter_param)
      return unless encounter_param['patient'] || encounter_param['patient_id']

      encounter_param['patient'].present? ? encounter_param['patient']['id'] : encounter_param['patient_id']
    end

    def set_patient_by_id(id)
      return unless id
      patient = Finder::Patient.find_by_institution(@institution, current_user).find(id)
      @encounter.patient = patient
      patient_blender = @blender.load(patient)
      @blender.merge_parent(@encounter_blender, patient_blender)
      patient_blender
    end

    def add_sample_by_uuid(uuid)
      sample = Finder::Sample.find_by_encounter_or_institution(@encounter, current_user, @encounter.institution).find_by!("sample_identifiers.uuid" => uuid)
      sample_blender = @blender.load(sample)
      @blender.merge_parent(sample_blender, @encounter_blender)
      sample_blender
    end

    def add_sample_by_uuids(uuids)
      sample_blender = merge_samples_by_uuid(uuids)
      @blender.merge_parent(sample_blender, @encounter_blender)
      sample_blender
    end

    def merge_samples_by_uuid(uuids)
      samples = Finder::Sample.find_by_encounter_or_institution(@encounter, current_user, @encounter.institution).where("sample_identifiers.uuid" => uuids).to_a
      raise ActiveRecord::RecordNotFound if samples.empty?
      target, *to_merge = samples.map{|s| @blender.load(s)}
      @blender.merge_blenders(target, to_merge)
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

    def create_new_samples
      @encounter.new_samples.each do |new_sample|
        add_new_sample_by_entity_id new_sample
      end
      @encounter.new_samples = []
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

    def store_create_encounter_audit_log
      Audit::EncounterAuditor.new(@encounter, current_user.id).log_changes(I18n.t('encounters_controller.test_order_created'), "#{@encounter.id}", @encounter)
      @encounter.requested_tests.each do |test|
        Audit::EncounterTestAuditor.new(@encounter, current_user.id).log_changes("#{I18n.t('encounters_controller.new')} #{test.name} #{I18n.t('encounters_controller.test_created')}", "#{I18n.t('encounters_controller.test')} #{test.name} #{I18n.t('encounters_controller.created_for')} #{@encounter.uuid}", @encounter, test)
      end
    end

    def new_sample_for_site
      sample = { entity_id: @encounter.site.generate_next_sample_entity_id! }
      @encounter.new_samples << sample
      sample
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
      matching_id = @institution.samples.joins(:sample_identifiers)
        .where("sample_identifiers.entity_id = ?", "#{sample[:entity_id]}")
      matching_id = matching_id.joins("LEFT JOIN encounters ON encounters.id = samples.encounter_id").where(patient_id: @encounter.patient_id) if @encounter.patient_id
      matching_id.count == 0
    end

    def add_test_result_by_uuid(uuid)
      test_result         = Finder::TestResults.find_by_institution(@institution, current_user).find_by!(uuid: uuid)
      test_result_blender = @blender.load(test_result)
      @blender.merge_parent(test_result_blender, @encounter_blender)
      test_result_blender
    end
  end
end
