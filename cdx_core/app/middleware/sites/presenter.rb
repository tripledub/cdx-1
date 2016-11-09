module Sites
  # Presenter for sites
  class Presenter
    class << self
      def index_table(sites)
        sites.map do |site|
          {
            id:       site.id,
            name:     site.name,
            city:     site.city,
            comment:  site.comment,
            viewLink: Rails.application.routes.url_helpers.edit_site_path(site.id)
          }
        end
      end

      def site_name(site)
        return '' unless site

        site.name
      end
    end
  end
end
