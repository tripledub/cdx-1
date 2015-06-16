class Subscriber < ActiveRecord::Base
  VALID_VERBS = %w(GET POST)

  belongs_to :user
  belongs_to :filter

  serialize :fields, JSON

  validates_presence_of :user
  validates_presence_of :filter
  validates_presence_of :name
  validates_presence_of :url
  validates_presence_of :verb
  validates_inclusion_of :verb, in: VALID_VERBS

  def self.notify_all
    PoirotRails::Activity.start("Subscriber.notify_all") do
      Subscriber.find_each do |subscriber|
        begin
          subscriber.notify
        rescue => ex
          Rails.logger.error "#{ex.message} : #{ex.backtrace}"
        end
      end
    end
  end

  def self.available_fields
    default_schema['properties'].keys.sort
  end

  def self.default_schema
    TestsSchema.new("en-US").build
  end

  def notify
    fields = self.fields
    filter = self.filter.query.merge "page_size" => 10000, "updated_at_since" => last_run_at.iso8601
    Rails.logger.info "Filter : #{filter}"
    tests = Cdx::Api::Elasticsearch::Query.new(filter.with_indifferent_access).execute["tests"]
    now = Time.now
    tests.each do |test|
      PoirotRails::Activity.start("Publish test to subscriber #{self.name}") do

        filtered_test = filter_test(test, fields)

        callback_url = self.url

        if self.verb == 'GET'
          callback_url = URI.parse self.url
          callback_query = Rack::Utils.parse_nested_query(callback_url.query || "")
          merged_query = filtered_test.merge(callback_query)
          callback_url = "#{callback_url.scheme}://#{callback_url.host}:#{callback_url.port}#{callback_url.path}?#{merged_query.to_query}"
        end

        options = {}
        if self.url_user && self.url_password
          options[:user] = self.url_user
          options[:password] = self.url_password
        end

        request = RestClient::Resource.new(callback_url, options)
        begin
          if self.verb == 'GET'
            request.get
          else
            request.post filtered_test.to_json
          end
        rescue Exception => ex
          Rails.logger.warn "Could not #{verb} to subscriber #{id} at #{callback_url}: #{ex.message}\n#{ex.backtrace}"
        end

      end
    end
    self.last_run_at = now
    self.save!
  end

  def filter_test(indexed_test, fields)
    test = TestResult.includes(:sample, :device, :institution).find_by_uuid(indexed_test['uuid'])
    merged_test = indexed_test.merge test.plain_sensitive_data.merge(test.sample.try(:plain_sensitive_data) || {})
    fields = Subscriber.available_fields if fields.nil? || fields.empty? # use all fields if none is specified
    fields_properties = self.class.default_schema['properties']
    filtered_test = {}

    fields.each do |field|
      if field == 'result'
        filtered_test["result"] = merged_test["results"].first["result"]
      elsif field == "condition"
        filtered_test["condition"] = merged_test["results"].first["condition"]
      elsif fields_properties[field] && fields_properties[field]['locations'].not_nil?
        filtered_test[field] = merged_test["#{field}_id"]
      elsif fields_properties[field] && fields_properties[field]['format'] == 'lat,lng'
        location_id_field_name = "#{fields_properties[field]['location_identifier']}_id"
        location = Location.find(merged_test[location_id_field_name])
        filtered_test[field] = "#{location.lat},#{location.lng}" if location
      elsif field == "institution_name"
        filtered_test[field] = test.institution.name
      elsif field == "laboratory_name" && indexed_test["laboratory_id"]
        filtered_test[field] = Laboratory.find(indexed_test["laboratory_id"]).try(:name)
      elsif field == "device_name"
        filtered_test[field] = test.device.name
      else
        filtered_test[field] = merged_test[field]
      end
    end
    filtered_test
  end
end
