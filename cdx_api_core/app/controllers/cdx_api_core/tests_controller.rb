module CdxApiCore
  class TestsController < CdxApiCore::ApiController
    wrap_parameters false

    def index
      params.delete(:format)
      params.delete(:controller)
      params.delete(:action)
      body = Oj.load(request.body.read) || {}
      filters = params.merge(body)
      query = TestResult.query(filters, current_user)
      respond_to do |format|
        format.csv do
          @filename = "Tests-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
          headers["Content-Type"] = "text/csv"
          headers["Content-disposition"] = "attachment; filename=#{@filename}"
          if query.grouped_by.empty?
            self.response_body = EntityCsvBuilder.new("test", query, @filename)
          else
            @csv_options = { col_sep: ',' }
            @csv_builder = CSVBuilder.new(
              query.execute[Cdx::Fields.test.result_name],
              column_names: query.grouped_by.concat(['count'])
            )
          end
        end
        format.json { render_json query.execute }
      end
    end

    def pii
      test = TestResult.find_by_uuid(params[:id])
      return unless authorize_resource(test, Policy::Actions::PII_TEST)
      render_json "uuid" => params[:id], "pii" => test.pii_data
    end

    def schema
      schema = TestsSchema.new params["locale"]
      respond_to do |format|
        format.json { render_json schema.build }
      end
    end
  end
end
