module Reports
  class DrtbPercentage < Results
    def generate_chart
      total_tests    = sum_total
      detected_tests = sum_detected
      data           = []
      data << { label: I18n.t('drtb_per.drtb_not_detected'), value: total_tests - detected_tests }
      data << { label: I18n.t('drtb_per.drtb_detected'),     value: detected_tests }
      {
        columns: data.each_with_index.map { |slice, i| { y: slice[:value], color: slice_colors[i], indexLabel: "#{slice[:label]} #percent%", legendText: slice[:label] } }
      }
    end

    protected

    def sum_total
      setup
      run_query
    end

    def sum_detected
      setup
      @query_or = [ 'patient_results.tuberculosis = ? OR patient_results.rifampicin = ?', 'detected', 'detected' ]
      run_query
    end
  end
end
