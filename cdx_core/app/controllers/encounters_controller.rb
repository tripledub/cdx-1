# Encounter controller
class EncountersController < ApplicationController
  before_action :load_encounter, only: [:show, :edit, :update, :destroy]
  before_action :find_institution_and_patient, only: [:new]
  before_action :patient_has_active_episodes, only: [:new]

  def new_index
    return unless authorize_resource(Site, CREATE_SITE_ENCOUNTER).empty?
  end

  def new
    determine_referal

    @possible_assay_results = TestResult.possible_results_for_assay
    return unless authorize_resource(Site, CREATE_SITE_ENCOUNTER).empty?
  end

  def create
    content, status = TestOrders::Persistence.new(params, current_user).create
    render json: content, status: status
  end

  def sites
    sites = check_access(@navigation_context.institution.sites, CREATE_SITE_ENCOUNTER)
    render json: Sites::Finder.as_json_list(sites.sort_by(&:name)).attributes!
  end

  def show
    return unless authorize_resource(@encounter, READ_ENCOUNTER)

    @test_order.prepare_blender_and_json(@encounter)
    @encounter_as_json = @test_order.as_json_edit.attributes!
    @barcode_available = @encounter.has_sample_ids?
    determine_referal
  end

  def edit
    return unless authorize_resource(@encounter, UPDATE_ENCOUNTER)
    if @encounter.has_dirty_diagnostic?
      @encounter.core_fields[Encounter::ASSAYS_FIELD] = @encounter.updated_diagnostic
      @test_order.prepare_blender_and_json(@encounter)
    end
    @possible_assay_results = TestResult.possible_results_for_assay
  end

  def destroy
    message = @test_order.destroy(@encounter)

    respond_to do |format|
      format.html { redirect_to patient_path(@encounter.patient), notice: message }
      format.json { head :no_content }
    end
  end

  def update
    content, status = @test_order.update
    render json: content, status: status
  end

  def search_sample
    @institution = Institutions::Finder.find_by_uuid(params[:institution_uuid], current_user)
    render json: Samples::Finder.find_as_json(@institution, current_user, params[:sample_uuids], params[:q]).attributes!
  end

  def add_sample
    content, status = TestOrders::Persistence.new(params, current_user).add_sample
    render json: content, status: status
  end

  def add_test
    content, status = TestOrders::Persistence.new(params, current_user).add_test
    render json: content, status: status
  end

  def merge_samples
    content, status = TestOrders::Persistence.new(params, current_user).merge_samples
    render json: content, status: status
  end

  def new_sample
    content, status = TestOrders::Persistence.new(params, current_user).new_sample
    render json: content, status: status
  end

  def add_sample_manually
    content, status = TestOrders::Persistence.new(params, current_user).add_sample_manually
    render json: content, status: status
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
        @show_cancel_encounter = true if @encounter && (@encounter.status == 'new')
        if @encounter && @encounter.patient
          @return_path_encounter = patient_path(@encounter.patient)
        else
          @return_path_encounter = referer
        end
      end
    end
  end

  def load_encounter
    @encounter = @navigation_context.institution.encounters.where('uuid = :id', params).first || @navigation_context.institution.encounters.where('id = :id', params).first
    redirect_to(encounters_path, notice: I18n.t('encounters.show.no_encounter')) && return unless @encounter.present?

    @encounter.new_samples = []
    @test_order = TestOrders::Persistence.new(params, current_user)
  end

  def find_institution_and_patient
    @institution = @navigation_context.institution
    redirect_to(test_orders_path, notice: I18n.t('encounters.new.no_patient')) unless @patient = Patients::Finder.find_by_institution(@institution, current_user).where(id: params[:patient_id]).first
  end

  def patient_has_active_episodes
    redirect_to(test_orders_path, notice: I18n.t('encounters.new.no_patient')) unless @patient.active_episodes?
  end
end
