module Sites
  # Export sites in csv format
  class CsvGenerator
    attr_reader :filename

    def initialize(sites, hostname)
      @sites = sites
      @hostname = hostname
    end

    def filename
      @filename || "#{@hostname}_sites_#{DateTime.now.strftime('%Y-%m-%d-%H-%M-%S')}.csv"
    end

    def build_csv
      CSV.generate(force_quotes: true) do |csv|
        csv << [
          I18n.t('sites_controller.col_name'),
          I18n.t('sites_controller.col_address'),
          I18n.t('sites_controller.col_city'),
          I18n.t('sites_controller.col_state'),
          I18n.t('sites_controller.col_zipcode')
        ]

        @sites.each do |s|
          csv << [s.name, s.address, s.city, s.state, s.zip_code]
        end
      end
    end
  end
end
