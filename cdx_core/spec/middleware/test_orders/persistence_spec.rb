require 'spec_helper'

RSpec.describe TestOrders::Persistence do
  let(:institution)            { Institution.make }
  let(:user)                   { institution.user }
  let(:site)                   { institution.sites.make }
  let(:patient)                { Patient.make   institution: institution }
  let(:encounter)              { Encounter.make institution: institution, user: user, patient: patient }
  let(:default_params)         { { context: institution.uuid } }
end
