module Import
  # Base class for JSON Import module. Used in admin/imports_controller.rb
  class Base

    attr_accessor :data, :objects, :errors, :clear_current_data

    def initialize(csv_data, clear_current_data)
      @data = csv_data
      @clear_current_data = clear_current_data.to_i > 0
      @objects = []
      @errors = []
    end

    # Instance methods
    def process
      return false if data.blank?

      clear_data if clear_current_data

      self.objects = JSON.parse(data)

      process_objects
    end

    def clear_data
      raise StandardError, 'Not implemented'
    end

    def process_objects
      ActiveRecord::Base.transaction do
        objects.each { |object| process_object(object.with_indifferent_access) }
      end

      true
    end

    # Class methods
    def self.import(params)
      raise StandardError, 'Invalid import_type' unless Import::IMPORT_TYPES.include?(params[:import_type])

      "Import::#{params[:import_type].classify.pluralize}".constantize.new(params[:file].read, params[:clear_current_data])
    end

  end
end
