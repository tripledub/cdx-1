module CsvGenerator
  class Sites
    attr_reader :filename

    def initialize(sites, name='Sites')
      @file_prefix = name
      @sites       = sites
    end

    def filename
      @filename || "#{@file_prefix}-#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def build_csv
      CSV.generate do |csv|
        csv << [I18n.t('sites_controller.col_name'), I18n.t('sites_controller.col_address'),I18n.t('sites_controller.col_city'), I18n.t('sites_controller.col_state'), I18n.t('sites_controller.col_zipcode')]
        @sites.each do |s|
          csv << [s.name, s.address, s.city, s.state, s.zip_code]
        end
      end
    end
  end
end
