# Device models Controller
class DeviceModelsController < ApplicationController

  before_action :find_device_model, only: [:show, :edit, :update, :publish, :manifest]
  before_action :find_unpublished_device_model, only: [:destroy]

  include DeviceModelsHelper

  before_filter do
    head :forbidden unless has_access_to_device_models_index?
  end

  def index
    @device_models = authorize_resource(DeviceModel, READ_DEVICE_MODEL) or return
    @device_models = @device_models.includes(:manifest)
    @device_models = @device_models.where(institution:  @navigation_context.institution)

    @total = @device_models.count

    order_by, offset = perform_pagination(table: 'devices_models_index', field_name: 'device_models.name')
    @device_models   = @device_models.order(order_by).limit(@page_size).offset(offset)
  end

  def show
    @device_model = authorize_resource(device_model, READ_DEVICE_MODEL) or return
    @manifest = @device_model.current_manifest
  end

  def new
    @device_model = @navigation_context.institution.device_models.new
    @device_model.manifest = Manifest.new

    return unless authorize_resource(@device_model, REGISTER_INSTITUTION_DEVICE_MODEL)
  end

  def create
    load_manifest_upload
    @device_model = @navigation_context.institution.device_models.new(device_model_create_params)
    return unless authorize_resource(@device_model, REGISTER_INSTITUTION_DEVICE_MODEL)
    set_published_status(@device_model)

    respond_to do |format|
      if @device_model.save
        format.html { redirect_to device_models_path, notice: I18n.t('device_models.create.success') }
        format.json { render action: 'show', status: :created, device_model: @device_model }
      else
        @device_model.published_at = @device_model.published_at_was
        @device_model.setup_instructions = nil
        format.html { render action: 'new' }
        format.json { render json: @device_model.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize_resource(@device_model, UPDATE_DEVICE_MODEL)
  end

  def update
    authorize_resource(@device_model, UPDATE_DEVICE_MODEL) || return
    (authorize_resource(@device_model, PUBLISH_DEVICE_MODEL) || return) if @device_model.published?
    set_published_status(@device_model)

    if params[:device_model][:manifest_attributes] &&
      (params['deleted_manifest'] == params["device_model"]["manifest_attributes"]["id"]) &&
      (params[:device_model][:manifest_attributes][:definition] == nil)
      cannot_delete_manifest = true
    end

    load_manifest_upload

    respond_to do |format|
      if cannot_delete_manifest
        flash.now[:error] = I18n.t('device_models.update.cannot_delete_manifest')
        format.html { render action: 'edit'}
      elsif @device_model.update(device_model_update_params)
        format.html { redirect_to device_models_path, notice: I18n.t('device_models.update.success', device_name: @device_model.name) }
        format.json { render action: 'show', status: :created, device_model: @device_model }
      else
        @device_model.published_at       = @device_model.published_at_was
        @device_model.setup_instructions = DeviceModel.find(params[:id]).setup_instructions
        format.html { render action: 'edit' }
        format.json { render json: @device_model.errors, status: :unprocessable_entity }
      end
    end
  end

  def publish
    authorize_resource(@device_model, PUBLISH_DEVICE_MODEL) or return
    set_published_status(@device_model)
    @device_model.save!

    respond_to do |format|
      format.html { redirect_to device_models_path, notice: I18n.t('device_models.update.success', device_name: @device_model.name, device_action: params[:publish] ? 'published' : 'withdrawn') }
      format.json { render action: 'show', status: :created, device_model: @device_model }
    end
  end

  def destroy
    authorize_resource(@device_model, DELETE_DEVICE_MODEL) or return
    @device_model.destroy!

    respond_to do |format|
      format.html { redirect_to device_models_path, notice: I18n.t('device_models.destroy.success') }
      format.json { head :no_content }
    end
  end

  def manifest
    authorize_resource(@device_model, READ_DEVICE_MODEL) or return
    @manifest = @device_model.current_manifest

    send_data @manifest.definition, type: :json, disposition: "attachment", filename: @manifest.filename
  end

  protected

  def find_device_model
    unless @device_model = @navigation_context.institution.device_models.where(id: params[:id]).first
      head :forbidden
      return false
    end
  end

  def find_unpublished_device_model
    unless @device_model = @navigation_context.institution.device_models.unpublished.find(params[:id])
      head :forbidden
      return false
    end
  end

  CREATE_PARAMS = [:institution_id]
  UPDATE_PARAMS = [:name, :picture, :delete_picture, :setup_instructions, :delete_setup_instructions, :supports_ftp, :filename_pattern, :supports_activation, :support_url, manifest_attributes: [:definition]]

  def device_model_create_params
    params.require(:device_model).permit(*(UPDATE_PARAMS + CREATE_PARAMS))
  end

  def device_model_update_params
    params.require(:device_model).permit(*UPDATE_PARAMS)
  end

  def set_published_status(device_model)
    device_model.set_published_at   if params[:publish]   && can_publish_device_model?(device_model)
    device_model.unset_published_at if params[:unpublish] && can_unpublish_device_model?(device_model)
  end

  def load_manifest_upload
    if params[:device_model][:manifest_attributes] && params[:device_model][:manifest_attributes][:definition]
      # this is for testing. specs had String manifest. It should be migrated to temp file and fixture_file_upload
      unless params[:device_model][:manifest_attributes][:definition].is_a?(String)
        params[:device_model][:manifest_attributes][:definition] = params[:device_model][:manifest_attributes][:definition].read
      end
    else
      params[:device_model][:manifest_attributes] ||= {}
      params[:device_model][:manifest_attributes][:definition] = @device_model.try { |dm| dm.current_manifest.definition }
    end
  end

end
