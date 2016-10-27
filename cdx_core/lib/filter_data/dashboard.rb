module FilterData
  # Filters for dashboard
  class Dashboard < Manager
    def filter_form_data
      {
        'range' => '',
        'since' => ''
      }
    end
  end
end
