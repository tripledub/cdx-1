require 'spec_helper'

describe Integration::Client do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:patient)             { Patient.make institution: institution, gender: 'male' }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:xpert_result)        { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago }
  let(:json)                { CdxVietnam::Presenters::Etb.create_patient(xpert_result) }

  context "in case scraper success sync" do
    before(:example) do
      episode = patient.episodes.make
      client = Integration::Client.new
      x = double('x')
      allow(Integration::CdpScraper::EtbScraper).to receive(:new).and_return(x)
      allow(x).to receive(:login)
      allow(x).to receive(:create_patient).and_return({:success => true, :patient_etb_id => '123456', :error => ""})
      allow(x).to receive(:create_test_order).and_return({:success => true, :error => ""})
      allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).and_return(json)
      client.integration(json)
    end

    it 'should update external system id after integrating' do
      expect(patient.reload.etb_patient_id).to eq('123456')
    end

    it 'should insert log after each integration' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.status).to eq('Finished')
    end

    it 'should mark patient result as is_synced after integration' do
      expect(xpert_result.reload.is_sync).to eq(true)
    end
  end
end
