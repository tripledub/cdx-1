module Extras
  # Helpers for select elements
  class Select
    class << self
      def find(select_options, term)
        return '' unless term.present?

        result = select_options.find { |e| e[0] == term }
        result ? result[1] : ''
      end

      def find_from_struct(struct, term)
        return '' unless term.present?

        result = struct.find { |e| e.id.to_s == term }
        result ? result.name : ''
      end
    end
  end
end
