module Auditable
  extend ActiveSupport::Concern

  included do
    def save_and_audit(current_user, title, comment='')
      if valid?
        new_record? ? audit_create(current_user, title, comment='') : audit_update(current_user, title, comment='')
      end

      save
    end

    def update_and_audit(attributes, current_user, title, comment='')
      with_transaction_returning_status do
        assign_attributes(attributes)
      end
      audit_update(current_user, title, comment='') if valid?

      save
    end

    def destroy_and_audit(current_user, title, comment='')
      audit_destroy(current_user, title, comment='')

      destroy
    end

    protected

    def audit_create(current_user, title, comment='')
      Audit::Auditor.new(patient_id, current_user.id).create(title, comment)
    end

    def audit_update(current_user, title, comment='')
      Audit::Auditor.new(patient_id, current_user.id).update(title, comment)
    end

    def audit_destroy
      Audit::Auditor.new(patient_id, current_user.id).destroy(title, comment)
    end

    def patient_id
      self.id
    end
  end
end
