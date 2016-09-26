module Audit
  # Convert strings with I18n elements into translated text
  # Do not use quotes inside t##
  # Example: t#patients.show.patient_name#
  # It also supports sending params to I18n.t
  # Example: t#patients.show.patient_name, patient.name#
  class TextTranslator
    class << self
      def localise(text)
        strings = /(.*?)t{(.*?)}(.+)/.match(text + ' ')
        strings ? "#{strings[1]}#{I18n.t(strings[2])}#{strings[3]}".strip : text
      end
    end
  end
end
