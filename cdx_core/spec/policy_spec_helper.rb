include Policy::Actions

def assert_can(user, resource, action, expected_result=nil)
  result = Policy.can? action, resource, user

  expect(result).to eq(true)

  result = Policy.authorize action, resource, user

  expected_result ||= resource

  if expected_result.kind_of?(Resource)
    expect(result).to eq(expected_result)
  else
    expect(result.to_a).to match_array(expected_result.to_a)
  end
end

def assert_cannot(user, resource, action)
  result = Policy.cannot? action, resource, user
  expect(result).to eq(true)
end

def grant(granter, user, resource, action, opts = {})
  [granter, user].compact.each(&:reload)
  policy = Policy.make_unsaved
  policy.definition = policy_definition(resource, action, opts.fetch(:delegable, true), opts.fetch(:except, []), opts.fetch(:include_subsites, false))
  policy.granter = granter
  policy.user = user
  policy.allows_implicit = true
  policy.save!
  policy
end

def policy_definition(resource, action, delegable = true, except = [], include_subsites = false)
  resource = Array.wrap(resource).map{|r| policy_resource_string_for(r)}
  except =   Array.wrap(except).map{|r| policy_resource_string_for(r)}
  action =   Array.wrap(action)

  JSON.parse %(
    {
      "statement": [
        {
          "action": #{action.to_json},
          "resource": #{resource.to_json},
          "except": #{except.to_json},
          "delegable": #{delegable},
          "includeSubsites": #{include_subsites}
        }
      ]
    }
  )
end

def policy_resource_string_for(resource)
  case resource
  when String
    resource
  when Symbol
    resource.to_s.camelize(:lower)
  when Hash
    res, condition = resource.to_a[0]
    str =  "#{policy_resource_string_for(res)}"
    case condition
    when Integer
      "#{str}/#{condition}"
    when Resource
      "#{str}?#{condition.resource_type}=#{condition.id}"
    else
      "#{str}?#{condition}"
    end
  else
    resource.resource_name
  end
end
