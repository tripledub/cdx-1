module Extras
  module Dates
    # Some utilities to format dates
    # This class takes care of handling the different formats in which dates are stored in the application.
    class Format
      class << self
        def string_to_pattern(string, input_format_pattern = I18n.t('date.input_format.pattern'))
          Date.strptime(string, input_format_pattern)
        rescue
          Date.today
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

        def datetime_with_time_zone(time_value, formatValue = :long, tz = nil)
          time_value = parse_select(time_value['1'], time_value['2'], time_value['3']) if time_value.is_a? Hash
          return nil unless time_value.present?

          time_value = if time_value.is_a?(String)
                         Time.parse(time_value)
                       elsif time_value.is_a?(Time)
                         tz ? time_value.in_time_zone(tz) : time_value
                       else
                         time_value
                       end

          I18n.l(time_value, format: formatValue)
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
  end
end
