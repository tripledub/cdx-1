module PatientResults
  # Returns an instance of a test result
  class Selector
    class << self
      def instance_from_string(test_type)
        if test_type.include? 'microscopy'
          MicroscopyResult.new
        elsif test_type.include? 'culture'
          CultureResult.new
        elsif test_type.include? 'xpert'
          XpertResult.new
        elsif test_type.include? 'drugsusceptibility'
          DstLpaResult.new
        end
      end
    end
  end
end
