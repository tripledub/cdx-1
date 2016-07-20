class Extras::Select
  class << self
    def find(select_options, term)
      return '' unless term.present?

      result = select_options.find { |e| e[0] == term }
      result[1] if result
    end

    def find_from_struct(struct, term)
      return '' unless term.present?

      result = struct.find { |e| e.id.to_s == term }
      result.name if result
    end
  end
end
