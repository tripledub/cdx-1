module CdxApiCore
  class EncountersController < CdxApiCore::ApiController
    wrap_parameters false

    def index
      params.delete(:format)
      params.delete(:controller)
      params.delete(:action)
      body = Oj.load(request.body.read) || {}
      filters = params.merge(body)
      query = TestOrders::Finder.new({}, filters)
      respond_to do |format|
        format.json { render_json query.filter_query }
      end
    end

    def pii
      encounter = Encounter.find_by_uuid(params[:id])
      return unless authorize_resource(encounter, Policy::Actions::PII_ENCOUNTER)
      render_json 'uuid' => params[:id], 'pii' => encounter.pii_data
    end

    def schema
      schema = EncountersSchema.new params['locale']
      respond_to do |format|
        format.json { render_json schema.build }
      end
    end
  end
end
