class Extras::Select
  class << self
    def find(select_options, term)
      result = select_options.find { |e| e[0] == term }
      result[1] if result
    end
  end
end
