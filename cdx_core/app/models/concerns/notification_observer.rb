module NotificationObserver
  extend ActiveSupport::Concern
  include ArTransactionChanges

  class_methods do
    def notification_observe_field(model_field, options = {})
      return if !options[:if].blank?     &&  options[:if]
      return if !options[:unless].blank? && !options[:unless]
      self._notification_observed_fields ||= []
      self._notification_observed_fields << model_field.to_sym if model_field
    end

    def notification_observe_fields(*model_fields)
      self._notification_observed_fields ||= []
      self._notification_observed_fields |= model_fields.map(&:to_sym)
    end

    def _has_observable_fields?
      !self._notification_observed_fields.blank?
    end
  end

  included do
    cattr_accessor :_notification_observed_fields

    after_commit :_fire_check_notification_job, if: :_has_observable_fields?

    def _has_observable_fields?
      self.class._has_observable_fields?
    end

    def _changed_attributes
      @_changed_attributes =
        previous_changes.inject({}) do |c, (k, v)|
          if transaction_changed_attributes.has_key?(k) && transaction_changed_attributes[k].blank?
            { k => [transaction_changed_attributes[k], self.send(k)] }
          elsif new_value = transaction_changed_attributes[k]
            { k => [new_value, v[1]] }
          else
            { k => v }
          end.merge(c)
        end
    end

    def _fire_check_notification_job
      selected_changed_attributes = _changed_attributes.select { |k, _v| self.class._notification_observed_fields.include?(k.to_sym) }
      !selected_changed_attributes.empty? &&
        CheckNotificationJob.perform_async(self.class, id, selected_changed_attributes)
    end
  end
end
