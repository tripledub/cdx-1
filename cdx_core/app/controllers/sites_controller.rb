class SitesController < ApplicationController
  set_institution_tab :sites

  respond_to :json, only: [:show, :create, :update, :destroy]

  before_filter do
    head :forbidden unless has_access_to_sites_index?
  end

  before_filter :find_site, only: [:show, :update, :destroy, :devices, :tests]

  def index
    @sites      = check_access(Site.within(@navigation_context.entity, @navigation_context.exclude_subsites), READ_SITE)
    @can_create = has_access?(@navigation_context.institution, CREATE_INSTITUTION_SITE)
    apply_filters

    respond_to do |format|
      format.html do
        @total           = @sites.count
        order_by, offset = perform_pagination(table: 'sites_index', field_name: 'sites.name')
        @sites           = @sites.order(order_by).limit(@page_size).offset(offset)
        render layout: false if request.xhr?
      end
      format.csv do
        csv_file = Sites::CsvGenerator.new(@sites)
        headers["Content-disposition"] = "attachment; filename=#{csv_file.filename}"
        self.response_body = csv_file.build_csv
      end
    end
  end

  def show
    render json: @site
  end

  def new
    @site  = Site.new
    @sites = check_access(Site, READ_SITE).within(@navigation_context.institution)
    @site.parent = @navigation_context.site
    authorize_resource(@site, CREATE_INSTITUTION_SITE)
  end

  # POST /sites
  # POST /sites.json
  def create
    @institution = @navigation_context.institution
    return unless authorize_resource(@institution, CREATE_INSTITUTION_SITE)
    @site  = @institution.sites.new(valid_params)
    @sites = check_access(@institution.sites, READ_SITE)

    respond_to do |format|
      if @site.save
        format.html { redirect_to sites_path, notice: I18n.t('sites.create.success') }
        format.json { render action: 'show', status: :created, location: @site }
      else
        format.html { render action: 'new' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @site = Site.with_deleted.find(params[:id])
    return unless authorize_resource(@site, READ_SITE)

    @can_move = !@site.deleted? && has_access?(@navigation_context.institution, CREATE_INSTITUTION_SITE)
    @can_edit = !@site.deleted? && has_access?(@site, UPDATE_SITE)
    if @can_edit
      @can_delete     = has_access?(@site, DELETE_SITE)
      @can_be_deleted = @site.devices.empty?
      @sites          = check_access(@navigation_context.institution.sites, READ_SITE) if @can_move
    end
  end

  # PATCH/PUT /sites/1
  # PATCH/PUT /sites/1.json
  def update
    redirect_to(sites_path, notice: I18n.t('sites.update.not_allowed', site_name: @site.name)) and return if !(authorize_resource(@site, UPDATE_SITE) && can_update_parent_site?)

    respond_to do |format|
      if @site.update(valid_params)
        format.html { redirect_to sites_path, notice: I18n.t('sites.update.success') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    return unless authorize_resource(@site, DELETE_SITE)

    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_path, notice: I18n.t('sites.destroy.success') }
      format.json { head :no_content }
    end
  end

  def devices
    return unless authorize_resource(@site, READ_SITE)
    @devices_to_edit = check_access(@site.devices, UPDATE_DEVICE).pluck(:id)
    render layout: false
  end

  def tests
    return unless authorize_resource(@site, READ_SITE)
    render layout: false
  end

  private

  def find_site
    @site = @navigation_context.institution.sites.find(params[:id])
  end

  def valid_params
    allowed_params = [:name, :address, :parent_id, :city, :state, :zip_code, :country, :region, :sample_id_reset_policy, :main_phone_number, :email_address, :allows_manual_entry, :comment]
    params.require(:site).permit(*allowed_params)
  end

  def apply_filters
    @sites = @sites.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
  end

  def can_update_parent_site?
    return true if valid_params[:parent_id] == @site.parent_id

    has_access?(@site.institution, CREATE_INSTITUTION_SITE)
  end
end
