module PatientResults
  # Finder for patient results
  class Finder
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
