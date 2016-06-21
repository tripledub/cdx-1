class Extras::Dates::Format
  class << self
    def string_to_pattern(string, input_format_pattern=I18n.t('date.input_format.pattern'))
      begin
        Date.strptime(string, input_format_pattern)
      rescue
        Date.today
      end
    end

    def datetime_with_time_zone(value, tz=nil)
      return nil unless value

      value = Time.parse(value) unless value.is_a?(Time)
      value = value.in_time_zone(tz) if tz
      I18n.localize(value, locale: I18n.locale, format: :long)
    end
  end
end
