class Array
  def substract(other_array, &are_equal)
    self.reject do |elem|
      other_array.any? do |other_elem|
        are_equal.call(elem, other_elem)
      end
    end
  end

  def get_in(*path)
    step = path.shift
    value = self[step]
    return value if path.empty?
    return nil if value.nil?
    value.get_in(*path)
  end
end
