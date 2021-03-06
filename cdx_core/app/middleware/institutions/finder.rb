module Institutions
  class Finder
    class << self
      def find_by_uuid(uuid, current_user)
        Policy.authorize(Policy::Actions::READ_INSTITUTION, ::Institution, current_user).where(uuid: uuid).first
      end

      def as_json(json, institution)
        json.(institution, :uuid, :name)
      end
    end
  end
end
