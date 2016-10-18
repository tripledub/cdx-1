# CDP Scraper Client for connecting to eTB and VTM systems
#
# @input patient [JSON] patient info
# @input test_order [JSON] patient's test orders (including results)
# @return [JSON] status
#
require 'mechanize'
require 'json'
require 'time'

module Integration
  module CdpScraper
    # The Base class for executing post/get as well as HTTP related tasks
    # To be extended by EtbScraper and VtmScraper
    #
    class Base
      # Take input from the target systems, usually it is a web application with authentication credentials
      def initialize(username, passwd, base_url, default_headers = {})
        @username = username
        @passwd = passwd
        @base_url = base_url
        @default_headers = { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }.merge(default_headers)
        @agent = Mechanize.new
        @agent.pre_connect_hooks << lambda { |agent, request| 
          request['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.116 Safari/537.36'
        }
      end
      
      # Helper method which helps check if a key does exists in an input params
      def check_key(key, array)
        return true if ![nil, '', '-'].include?(array[key])
        raise RuntimeError, "#{key} is empty"
      end
      
      # Check if a key is of valid values
      def check_valid(key, array, values)
        return true if [nil, '', '-'].include?(array[key])
        return true if values.map(&:to_s).include?(array[key].to_s)
        raise RuntimeError, "Invalid value for #{key}"
      end
      
      # Executing a HTTP POST request using the provided data
      def post(url, post_data, custom_headers = {})
        headers = @default_headers.merge(custom_headers)
        # slow down the request rate! otherwise you will get blocked
        sleep 1
        return @agent.post(url, post_data, headers)
      end
      
      # Executing a HTTP GET request using the provided data
      def get(url)
        # slow down the request rate! otherwise you will get blocked
        sleep 1
        return @agent.get(url)
      end
      
      # Return the full URI for a path
      def uri(path)
        return File.join(@base_url, path)
      end

      # replace empty values with valid specific string/text for the target system
      def replace_empty(key, params, empty_str)
        params[key] = empty_str if [nil, '', '-'].include?(params[key])
        return params
      end
      
      # Execute a request without automatically follow a [HTTP 301 Redirect] directive
      def without_redirect(&block)
        if block_given?
          @agent.redirect_ok = false
          yield
          @agent.redirect_ok = true
        end
      end
    end
  end
end
