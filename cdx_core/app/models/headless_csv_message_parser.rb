class HeadlessCSVMessageParser
  DEFAULT_SEPARATOR = ";"

  def initialize(separator=DEFAULT_SEPARATOR)
    @separator = separator
  end

  def lookup(path, data, root = data)
    unless ManifestFieldValidation.is_an_integer?(path)
      raise I18n.t('models.headless_csv_message_parser.header_lookup')
    else
      data[path.to_i]
    end
  end

  def load(data, root_path = nil)
    CSV.new(data, col_sep: @separator)
  end
end
