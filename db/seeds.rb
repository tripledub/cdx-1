if defined? CdxVietnam
  [
    { prefix: 'nlh', name: 'NLH Production HIS' },
    { prefix: 'hlh', name: 'HLH Production HIS' },
    { prefix: 'log', name: 'Log Book' },
    { prefix: 'vit', name: 'Vitimes' },
    { prefix: 'etb', name: 'E-TB Manager' }
  ].each do |system|
    extsys = ExternalSystem.where(prefix: system[:prefix]).first_or_create
    extsys.update_attributes(system)
  end
end
