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

end
