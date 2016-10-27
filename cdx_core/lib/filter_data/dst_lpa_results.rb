module FilterData
  # Filters for dst_lpa results
  class DstLpaResults < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'test_results_tabs_selected_tab' => '',
        'media' => '',
        'results_h' => '',
        'results_r' => '',
        'results_e' => '',
        'results_s' => '',
        'results_amk' => '',
        'results_km' => '',
        'results_cm' => '',
        'results_fq' => '',
        'since' => '',
        'from_datte' => '',
        'to_date' => '',
        'sample.id' => '',
      }
    end
  end
end
