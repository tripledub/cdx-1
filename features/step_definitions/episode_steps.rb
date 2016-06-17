include CdxPageHelper

Given(/^an authenticated clinician called Barney$/) do
  @clinician = User.make(password: 'admin123', first_name: 'Barney')
  @institution = Institution.make user_id: @clinician.id
  @clinician.grant_superadmin_policy
  @clinician.reload.update_computed_policies
  authenticate(@clinician)
  default_params =  {context: @institution.uuid}
  @navigation_context = NavigationContext.new(@clinician, default_params[:context])
end

Given(/^a patient called "(.*?)"$/) do |patient_name|
  @patient = Patient.create(name: patient_name)
  @patient.institution = @institution
  @patient.save!
end

When(/^Barney views Freds patient details card$/) do
  @episode_page = EpisodePage.new
  @episode_page.load(patient_id: @patient.id, query: { context: @institution.uuid})
end

Then(/^he should see the New Episode tab$/) do
  @episode_page.should have_content('New Episode')
end

Then(/^he should see the correct fields$/) do
  pending # express the regexp above with the code you wish you had
end
