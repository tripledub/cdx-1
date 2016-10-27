module FilterData
  # Perform basic operations on filters
  class Manager
    attr_reader :params, :current_data

    def initialize(params, cookies)
      @params = params
      @cookies = cookies
      @current_data = get_cookie
    end

    def update
      current_data.each_key { |key| update_field(key, @params[key]) }
      save_cookie
      set_params
    end

    protected

    def update_field(filter_name, filter_value)
      current_data[filter_name.to_s] = filter_value if filter_value
    end

    def get_cookie
      @cookies[filter_form_name.to_s].present? ? JSON.parse(@cookies[filter_form_name]) : filter_form_data
    end

    def save_cookie
      @cookies[filter_form_name.to_s] = { value: current_data.to_json, expires: 1.year.from_now }
    end

    def set_params
      current_data.each { |key, value| @params[key] = value }
    end
  end
end
