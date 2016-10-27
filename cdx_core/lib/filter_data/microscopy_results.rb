module FilterData
  # Filters for microscopy results
  class MicroscopyResults < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'test_results_tabs_selected_tab' => '',
        'appearance' => '',
        'test_result' => '',
        'since' => '',
        'from_datte' => '',
        'to_date' => '',
        'sample.id' => '',
      }
    end
  end
end
