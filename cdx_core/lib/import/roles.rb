module Import
  # Import Role data into CDX. If supplied User is missing it
  # will also be created based off email address/password.
  class Roles < Import::Base
    def clear_data
      # Remove Roles
      Role.delete_all
      # Remove Policies
      Policy.delete_all
      # Remove Computed Policies except superadmin
      ComputedPolicy.where.not(user_id: User.first).delete_all
      # Remove Computed Policy Exceptions
      ComputedPolicyException.delete_all
    end

    def import_user(email, password)
      user = User.find_by(email: email)

      if user.blank?
        user = User.new(email: email)
        user.password = password
        user.save!
      end

      user
    end

    def process_object(object)
      Rails.logger.info object.inspect
      return if object.blank?
      return if object[:email].blank? ||
                object[:password].blank? ||
                object[:institution].blank? ||
                object[:role_label].blank? ||
                object[:definition].blank?

      Rails.logger.info "Import user"
      user = import_user(object[:email], object[:password])

      Rails.logger.info "Import institution"
      unless (institution = Institution.where('lower(name) = ?', object[:institution].downcase).first)
        institution = Institution.create!(name: object[:institution], user: User.first)
      end

      if object[:site]
        Rails.logger.info "Import site"
        unless (site = institution.sites.where('lower(name) = ?', object[:site].downcase).first)
          site = institution.sites.create!(name: object[:site])
        end
      end

      Rails.logger.info "Import role"
      unless (role = institution.roles.where('lower(name) = ?', object[:role_label].downcase).first)
        role = institution.roles.build(name: object[:role_label])
      end

      Rails.logger.info "Create policy"
      definition = object[:definition].to_json
      definition.gsub!(/\{\{INSTITUTION_ID\}\}/i, institution.id.to_s)
      definition.gsub!(/\{\{SITE_ID\}\}/i, site.id.to_s) if object[:site]
      role.policy = Policy.create!(name: role.name, user: user, definition: JSON.parse(definition), allows_implicit: true)

      role.save!

      user.roles << role

      ComputedPolicy.update_user(user)

      true
    end
  end
end
