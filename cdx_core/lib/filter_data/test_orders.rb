module FilterData
  # Filters for test orders
  class TestOrders < Manager
    def filter_form_name
      'test_orders'
    end

    def filter_form_data
      {
        'page_size': '10',
        'testing_for': '',
        'status': '',
        'since': ''
      }
    end
  end
end
