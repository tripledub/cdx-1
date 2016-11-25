module FilterData
  # Filters for devices
  class Devices < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'device_model' => ''
      }
    end
  end
end
