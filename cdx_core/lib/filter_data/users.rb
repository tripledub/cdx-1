module FilterData
  # Filters for users
  class Users < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'name' => '',
        'role' => '',
        'last_activity' => '',
        'is_active' => ''
      }
    end
  end
end
