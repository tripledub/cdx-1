module CdxApiCore
  # API Institutions controller
  class InstitutionsController < CdxApiCore::ApiController
    def index
      @institutions = check_access(Institution, READ_INSTITUTION).map do |i|
        { 'uuid' => i.uuid, 'name' => i.name }
      end

      @institutions.sort! { |a, b| a['name'] <=> b['name'] }

      respond_to do |format|
        format.json do
          render_json(
            total_count: @institutions.size,
            institutions: @institutions
          )
        end
      end
    end
  end
end
