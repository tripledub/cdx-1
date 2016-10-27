module FilterData
  # Filters for culture results
  class CultureResults < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'test_results_tabs_selected_tab' => '',
        'media' => '',
        'test_result' => '',
        'since' => '',
        'from_datte' => '',
        'to_date' => '',
        'sample.id' => '',
      }
    end
  end
end
