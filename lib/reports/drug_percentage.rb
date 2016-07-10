module Reports
  class DrugPercentage < Results
    def generate_chart
      data           = []
      data << { label: 'INH detected',       value: sum_inh }
      data << { label: 'RIF detected',       value: sum_rif }
      data << { label: 'RIF & INH detected', value: sum_both_detected }
      {
        columns: data.each_with_index.map { |slice, i| { y: slice[:value], color: slice_colors[i], indexLabel: "#{slice[:label]} #percent%", legendText: slice[:label] } }
      }
    end

    protected

    def query_data
      XpertResult
    end

    def sum_inh
      setup
      query_conditions.merge!({ 'patient_results.tuberculosis': 'detected'})
      run_query
    end

    def sum_rif
      setup
      query_conditions.merge!({ 'patient_results.rifampicin': 'detected' })
      run_query
    end

    def sum_both_detected
      setup
      query_conditions.merge!({ 'patient_results.tuberculosis': 'detected', 'patient_results.rifampicin': 'detected' })
      run_query
    end
  end
end
