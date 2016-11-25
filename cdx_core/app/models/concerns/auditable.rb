# Adds methods to models that we want to audit.
# Those models should respond to patient or be a patient itself.
module Auditable
  extend ActiveSupport::Concern

  included do
    def save_and_audit(title, comment = '')
      if valid?
        audit_content(title, comment)
        return true
      end

      false
    end

    def update_and_audit(attributes, title, comment = '')
      with_transaction_returning_status do
        assign_attributes(attributes)
      end

      audit_update(title, comment) if valid?

      save
    end

    def destroy_and_audit(title, comment = '')
      audit_action(title, comment)

      destroy
    end

    protected

    def audit_action(title, comment = '')
      Audit::Auditor.new(self).log_action(title, comment)
    end

    def audit_update(title, comment = '')
      Audit::Auditor.new(self).log_changes(title, comment)
    end

    def audit_content(title, comment)
      if new_record?
        save
        audit_action(title, comment)
      else
        audit_update(title, comment)
        save
      end
    end
  end
end
