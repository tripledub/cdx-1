include CdxPageHelper

Given(/^the user has a user account$/) do
  @user = User.make(password: '12345678', first_name: 'Bob', email: 'zaa1aa@ggg.com')
  @institution = Institution.make user_id: @user.id
  @user.grant_superadmin_policy
  authenticate(@user)

  #needed for the @sites
  default_params =  {context: @institution.uuid}
  @navigation_context = NavigationContext.new(@user, default_params[:context])
end

And (/^test results exist$/) do
  site = @navigation_context.entity.sites.make
  device = site.devices.make
  
  TestResult.make(
    core_fields: {
      'assays' => ['condition' => 'mtb', 'result' => :positive],
      'start_time' => Time.now,
      'type' => 'specimen',
      'name' => 'mtb',
      'status' => 'success'
    },
    device_messages:[DeviceMessage.make(device: device)]
  )

  TestResult.make(
    core_fields: {
      'assays' => ['condition' => 'mtb', 'result' => :positive],
      'start_time' => Time.now - 1.day,
      'type' => 'specimen',
      'name' => 'mtb',
      'status' => 'error',
      'error_code' => '11'
    },
    device_messages:[DeviceMessage.make(device: device)]
  )
 
end


Then (/^the user views all test results "(.*?)"$/) do |arg1|
  @testresult = TestResultsPage.new
  @testresult.load
   expect(@testresult.table).to have_css("tbody tr", count: arg1)
end


