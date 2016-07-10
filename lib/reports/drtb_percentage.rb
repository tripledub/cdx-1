module Reports
  class DrtbPercentage < Results
    def generate_chart
      total_tests    = sum_total
      detected_tests = sum_detected
      data           = []
      data << { label: 'DR-TB not detected', value: total_tests - detected_tests }
      data << { label: 'DR-TB detected',     value: detected_tests }
      {
        columns: data.each_with_index.map { |slice, i| { y: slice[:value], color: slice_colors[i], indexLabel: "#{slice[:label]} #percent%", legendText: slice[:label] } }
      }
    end

    protected

    def query_data
      XpertResult
    end

    def sum_total
      setup
      run_query
    end

    def sum_detected
      setup
      query_conditions.merge!({ 'patient_results.tuberculosis': 'detected' })
      run_query
    end
  end
end
