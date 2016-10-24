module Reports
  class DrugPercentage < Results
    def generate_chart
      data           = []
      data << { label: I18n.t('drug_per.inh_detected'),       value: sum_inh }
      data << { label: I18n.t('drug_per.rif_detected'),       value: sum_rif }
      data << { label: I18n.t('drug_per.rif_inh_detected'), value: sum_both_detected }
      {
        columns: data.each_with_index.map { |slice, i| { y: slice[:value], color: slice_colors[i], indexLabel: "#{slice[:label]} #percent%", legendText: slice[:label] } }
      }
    end

    protected

    def sum_inh
      setup
      @query_conditions.merge!({ 'patient_results.tuberculosis': 'detected'})
      run_query
    end

    def sum_rif
      setup
      @query_conditions.merge!({ 'patient_results.rifampicin': 'detected' })
      run_query
    end

    def sum_both_detected
      setup
      @query_conditions.merge!({ 'patient_results.tuberculosis': 'detected', 'patient_results.rifampicin': 'detected' })
      run_query
    end
  end
end
