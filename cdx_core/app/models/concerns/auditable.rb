# Adds methods to models that we want to audit.
# Those models should respond to patient or be a patient itself.
module Auditable
  extend ActiveSupport::Concern

  included do
    def save_and_audit(current_user, title, comment = '')
      if valid?
        audit_content(current_user, title, comment)
        return true
      end

      false
    end

    def update_and_audit(attributes, current_user, title, comment = '')
      with_transaction_returning_status do
        assign_attributes(attributes)
      end

      audit_update(current_user, title, comment) if valid?

      save
    end

    def destroy_and_audit(current_user, title, comment = '')
      audit_action(current_user, title, comment)

      destroy
    end

    protected

    def audit_action(current_user, title, comment = '')
      Audit::Auditor.new(self, current_user.id).log_action(title, comment)
    end

    def audit_update(current_user, title, comment = '')
      Audit::Auditor.new(self, current_user.id).log_changes(title, comment)
    end

    def audit_content(current_user, title, comment)
      if new_record?
        save
        audit_action(current_user, title, comment)
      else
        audit_update(current_user, title, comment)
        save
      end
    end
  end
end
