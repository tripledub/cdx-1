module FilterData
  # Filters for test orders
  class TestOrders < Manager
    def filter_form_data
      {
        'page_size' => '10',
        'testing_for' => '',
        'status' => '',
        'since' => '',
        'batch_id' => ''
      }
    end
  end
end
