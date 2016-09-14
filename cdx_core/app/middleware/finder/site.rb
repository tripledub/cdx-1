module Finder
  class Site
    class << self
      def find_by_uuid(uuid, current_user, institution)
        Policy.authorize(CREATE_SITE_ENCOUNTER, institution.sites, current_user).where(uuid: uuid).first
      end

      def as_json(json, site)
        json.(site, :uuid, :name, :allows_manual_entry)
      end
    end
  end
end
