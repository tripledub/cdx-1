require 'spec_helper'

RSpec.describe PatientResults::Finder do
  let(:user)               { User.make }
  let!(:institution)       { user.institutions.make }
  let(:site)               { Site.make institution: institution }
  let(:site2)              { Site.make institution: institution }
  let(:site3)              { Site.make institution: institution, parent_id: site2.id }
  let(:patient)            { Patient.make institution: institution }
  let(:patient2)           { Patient.make institution: institution, site: site2 }
  let(:patient3)           { Patient.make institution: institution, site: site3 }
  let(:encounter)          { Encounter.make patient: patient }
  let(:encounter2)         { Encounter.make patient: patient2, site: site2 }
  let(:encounter3)         { Encounter.make patient: patient3, site: site3 }
  let(:device)             { Device.make  institution: institution, site: site }
  let(:device2)            { Device.make  institution: institution, site: site2 }
  let(:device3)            { Device.make  institution: institution, site: site3 }
  let!(:test_result)       { XpertResult.make encounter: encounter, institution: institution, device: device, result_at:  3.days.ago.strftime('%Y-%m-%d') }
  let!(:test_result2)      { MicroscopyResult.make encounter: encounter, institution: institution, device: device2, result_at: 16.days.ago.strftime('%Y-%m-%d') }
  let!(:test_result3)      { DstLpaResult.make encounter: encounter2, institution: institution, device: device3, result_at: 28.days.ago.strftime('%Y-%m-%d'), sample_identifier: sample_identifier }
  let!(:test_result4)      { CultureResult.make encounter: encounter3, institution: institution, device: device, result_at: 53.days.ago.strftime('%Y-%m-%d') }
  let(:navigation_context) { NavigationContext.new(user, institution.uuid) }
  let(:sample_identifier)  { SampleIdentifier.make }
  let(:params) { { } }

  describe '#finder_query' do
    context 'when navigation context is the institution' do
      subject { described_class.new(navigation_context, { 'since' => 99.days.ago.strftime("%Y-%m-%d") }) }

      it 'should return an active record relation' do
        expect(subject.filter_query).to be_kind_of(ActiveRecord::Relation)
      end

      it 'should return all test results from that institution' do
        expect(subject.filter_query.count).to eq(4)
      end
    end

    context 'when navigation context is a site with subsites' do
      let(:navigation_context) { NavigationContext.new(user, site2.uuid) }

      subject { described_class.new(navigation_context, { 'since' => 99.days.ago.strftime("%Y-%m-%d") }) }

      it 'should return all test orders from that site and subsites' do
        expect(subject.filter_query.count).to eq(2)
      end
    end

    context 'when navigation context is a site with no subsites' do
      let(:navigation_context) { NavigationContext.new(user, "#{site2.uuid}-!") }

      subject { described_class.new(navigation_context, { 'since' => 99.days.ago.strftime("%Y-%m-%d") }) }

      it 'should return all test orders from that site' do
        expect(subject.filter_query.count).to eq(1)
      end
    end

    context 'when filtering by device' do
      subject { described_class.new(navigation_context, { 'device_uuid' => device.uuid, 'since' => 99.days.ago.strftime("%Y-%m-%d") }) }

      it 'should show results from that device only' do
        expect(subject.filter_query.count).to eq(2)
      end

      it 'should return the requested results' do
        expect(subject.filter_query).to include(test_result)
        expect(subject.filter_query).to include(test_result4)
      end
    end

    context 'Since' do
      subject { described_class.new(navigation_context, params) }

      it 'should return the last 7 days results' do
        expect(subject.filter_query.count).to eq(1)
      end

      it 'should return the encounter data' do
        expect(subject.filter_query).to include(test_result)
      end
    end

    context 'Sample Identifier' do
      subject { described_class.new(navigation_context, { 'sample_id' => test_result3.sample_identifier.id, 'since' => 99.days.ago.strftime("%Y-%m-%d") }) }

      it 'should return results with that status' do
        expect(subject.filter_query.count).to eq(1)
      end

      it 'should return the encounter data' do
        expect(subject.filter_query).to include(test_result3)
      end
    end
  end
end
