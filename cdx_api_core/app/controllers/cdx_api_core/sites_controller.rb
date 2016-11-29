module CdxApiCore
  # API sites controller
  class SitesController < CdxApiCore::ApiController
    def index
      @sites = if params[:institution_uuid]
                 Institution.find_by_uuid(params[:institution_uuid]).sites
               else
                 Site.all
               end

      @uuids = Set.new
      @sites = check_access(@sites, READ_SITE).map do |site|
        @uuids << site.uuid

        { 'uuid' => site.uuid, 'name' => site.name, 'parent_uuid' => site.parent.try(:uuid), 'institution_uuid' => site.institution.uuid }
      end

      @sites.each do |site|
        site['parent_uuid'] = nil unless @uuids.include?(site['parent_uuid'])
      end

      @sites.sort! { |a, b| a['name'] <=> b['name'] }

      respond_to do |format|
        format.json do
          render_json(total_count: @sites.size, sites: @sites)
        end
      end
    end
  end
end
