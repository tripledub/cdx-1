module FilterData
  # Perform basic operations on filters
  class Manager
    attr_reader :params, :current_data, :name

    def initialize(params, cookies)
      @params = params
      @cookies = cookies
      @current_data = get_cookie
    end

    def update
      current_data.each_key { |key| update_field(key, @params[key.to_s]) }
      set_params
    end

    protected

    def update_field(filter_name, filter_value)
      current_data[filter_name.to_s] = filter_value if filter_value
    end

    def get_cookie
      @cookies[name].present? ? JSON.parse(@cookies[name]) : filter_form_data
    end

    def set_params
      current_data.each { |key, value| @params[key.to_s] = value }
    end
  end
end
