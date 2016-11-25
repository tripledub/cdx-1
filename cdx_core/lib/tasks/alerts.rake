task remove_alerts_from_policies: :environment do

  Policy.all.each do |policy|
    policy.definition['statement'].map do |definition|
      if definition['resource'].is_a?(Array)
        definition['resource'].map! do |action|
          action.gsub(/alert/, 'notification')
        end
      else
        definition['resource'].gsub!(/alert/, 'notification')
      end

      if definition['action'].is_a?(Array)
        definition['action'].map! do |action|
          action.gsub(/alert/, 'notification')
        end
      else
        definition['action'].gsub!(/alert/, 'notification')
      end

      definition
    end

    policy.update_column(:definition, policy.definition)
  end

  ComputedPolicy.where(resource_type: 'alert').update_all(resource_type: 'notification')
end

task migrate_alerts_conditions: :environment do
  Notification.all.each do |notification|
    if notification.detection == 'mtb'
      if notification.detection_condition == 'positive'
        notification.notification_conditions.create(condition_type: 'XpertResult', field: 'tuberculosis', value: 'detected')
      elsif notification.detection_condition == 'negative'
        notification.notification_conditions.create(condition_type: 'XpertResult', field: 'tuberculosis', value: 'not_detected')
      end
    elsif notification.detection == 'rif'
      if notification.detection_condition == 'positive'
        notification.notification_conditions.create(condition_type: 'XpertResult', field: 'rifampicin', value: 'detected')
      elsif notification.detection_condition == 'negative'
        notification.notification_conditions.create(condition_type: 'XpertResult', field: 'rifampicin', value: 'not_detected')
      end
    end

    if(notification.respond_to?(:notification_statuses_names))
      notification.notification_statuses_names.each do |status|
        %w(
          CultureResult
          DstLpaResult
          MicroscopyResult
          XpertResult
        ).each do |klass|
          notification.notification_conditions.create(condition_type: klass, field: 'result_status', value: status)
        end
      end
    end
  end
end

task convert_notice_groups: :environment do
  Notification::NoticeGroup.update_all(email_messages: nil, sms_messages: nil)

  Notification::NoticeGroup.all.each do |group|
    group.send(:collate_notification_messages)
    group.save!
  end
end
