class Cdx::Api::Elasticsearch::Config

  def api_fields=(api_fields)
    @api_fields = api_fields.with_indifferent_access
  end

  def api_fields
    unless @api_fields
      self.api_fields = YAML.load_file(File.expand_path("../../../../../config/cdx_api_fields.yml", __FILE__))
    end
    @api_fields
  end

  def api_fields_filename(api_fields_filename)
    self.api_fields = YAML.load_file(api_fields_filename)
  end

  attr_accessor :index_name_pattern
  attr_accessor :log
  attr_accessor :document_format

  def searchable_fields
    @searchable_fields ||= api_fields[:searchable_fields].map do |definition|
      Cdx::Api::Elasticsearch::IndexedField.from(definition,document_format)
    end
  end

  def document_format=(document_format)
    @document_format = document_format
  end

  def document_mappings=(mappings)
    @document_format = Cdx::Api::Elasticsearch::CustomDocumentFormat.new(mappings)
  end

  def document_format
    @document_format || CDPDocumentFormat.new
  end

end