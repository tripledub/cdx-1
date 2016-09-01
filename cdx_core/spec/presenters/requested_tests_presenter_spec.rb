require 'spec_helper'

RSpec.describe Presenters::RequestedTests do
  let(:user) { User.make }
  let!(:institution) { user.institutions.make }
  let(:site) { Site.make institution: institution }
  let(:performing_site) { Site.make institution: institution }
  let(:patient) { Patient.make institution: institution, name: 'Nico McBrian' }
  let(:encounter) do
    Encounter.make(
      institution: institution,
      site: site,
      patient: patient,
      start_time: 3.days.ago.to_s,
      testdue_date: 1.day.from_now.to_s,
      status: 2,
      testing_for: 'TB',
      performing_site: performing_site
    )
  end

  describe 'index_view' do
    before :each do
      4.times do
        RequestedTest.make(encounter: encounter)
      end
      encounter.reload
    end

    subject { Presenters::RequestedTests.index_view(encounter) }

    it 'returns an array of formatted test requests' do
      expect(subject).to be_a(Array)
      expect(subject.size).to eq(4)
    end

    it 'returns all elements correctly formatted' do
      rt = RequestedTest.first
      expect(subject.first).to eq(
        id: rt.id,
        turnaround: rt.turnaround,
        comment: rt.comment,
        completed_at: rt.completed_at,
        created_at: rt.created_at,
        datetime: rt.datetime,
        encounter_id: rt.encounter_id,
        name: rt.name,
        status: rt.status,
        updated_at: rt.updated_at
      )
    end
  end
end
