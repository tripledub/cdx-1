module FilterData
  # Filters for device results
  class DeviceResults < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'test_results_tabs_selected_tab' => '',
        'test.assays.condition' => '',
        'test.assays.result' => '',
        'since' => '',
        'from_date' => '',
        'to_date' => '',
        'test.type' => '',
        'test.status' => '',
        'sample.id' => '',
        'device.uuid' => ''
      }
    end
  end
end
