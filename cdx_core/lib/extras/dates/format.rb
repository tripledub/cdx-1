class Extras::Dates::Format
  class << self
    def string_to_pattern(string, input_format_pattern=I18n.t('date.input_format.pattern'))
      begin
        Date.strptime(string, input_format_pattern)
      rescue
        Date.today
      end
    end

    def parse_select(year, month, day)
      return unless year.present?
      month = 1 unless month.present?
      day   = 1 unless day.present?
      begin
        Date.new(year, month, day)
      rescue
        nil
      end
    end

    def datetime_with_time_zone(timeValue, formatValue=:long, tz=nil)
      timeValue = parse_select(timeValue['1'], timeValue['2'], timeValue['3']) if timeValue.is_a? Hash
      return nil unless timeValue.present?

      timeValue = if timeValue.is_a?(String)
        Time.parse(timeValue)
      elsif timeValue.is_a?(Time)
        tz ? timeValue.in_time_zone(tz) : timeValue
      else
        timeValue
      end

      I18n.l(timeValue, format: formatValue)
    end

    def patient_birth_date(birth_date_on)
      return unless birth_date_on

      "#{I18n.l(birth_date_on, format: :full_date)} - #{birth_date_on_to_words(birth_date_on)}"
    end

    protected

    def birth_date_on_to_words(birth_date_on)
      years = Date.today.year - birth_date_on.year

      if years > 1
        "#{years}y/o."
      else
        months = (Date.today.year * 12 + Date.today.month) - (birth_date_on.year * 12 + birth_date_on.month)
        "#{months}m/o."
      end
    end
  end
end
