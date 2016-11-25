module FilterData
  # Filters for patients
  class Patients < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'name' => '',
        'entity_id' => '',
        'since_dob' => '',
        'until_dob' => '',
        'address' => ''
      }
    end
  end
end
