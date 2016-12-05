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

  context "in case scraper fail sync in create_patient step" do
    before(:example) do
      episode = patient.episodes.make
      client = Integration::Client.new
      x = double('x')
      allow(Integration::CdpScraper::EtbScraper).to receive(:new).and_return(x)
      allow(x).to receive(:login)
      allow(x).to receive(:create_patient).and_return({:success => false, :patient_etb_id => '123456', :error => "fail to sync"})
      allow(x).to receive(:create_test_order).and_return({:success => true, :error => ""})
      allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).and_return(json)
      client.integration(json)
    end

    it 'should not update external system id after integrating' do
      expect(patient.reload.etb_patient_id).to eq(nil)
    end

    it 'should insert patient fail step to log' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.fail_step).to eq('patient')
    end

    it 'should insert log after each integration' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.status).to eq('Error')
    end

    it 'should mark patient result as is_synced after integration' do
      expect(xpert_result.reload.is_sync).to eq(false)
    end
  end

  context "in case scraper fail sync in create_test_order step" do
    before(:example) do
      episode = patient.episodes.make
      client = Integration::Client.new
      x = double('x')
      allow(Integration::CdpScraper::EtbScraper).to receive(:new).and_return(x)
      allow(x).to receive(:login)
      allow(x).to receive(:create_patient).and_return({:success => true, :patient_etb_id => '123456', :error => ""})
      allow(x).to receive(:create_test_order).and_return({:success => false, :error => ""})
      allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).and_return(json)
      client.integration(json)
    end

    it 'should update external system id after integrating' do
      expect(patient.reload.etb_patient_id).to eq('123456')
    end

    it 'should insert test_order fail step to log' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.fail_step).to eq('create_test_order')
    end

    it 'should insert log after each integration' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.status).to eq('Error')
    end

    it 'should mark patient result as is_synced after integration' do
      expect(xpert_result.reload.is_sync).to eq(false)
    end
  end

  context "in case scraper success sync with etb patient exited" do
    let(:patient)             { Patient.make institution: institution, gender: 'male', etb_patient_id: "3456" }
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
      expect(patient.reload.etb_patient_id).to eq('3456')
    end

    it 'should insert log after each integration' do
      expect(IntegrationLog.all.size).to eq(1)
      expect(IntegrationLog.first.status).to eq('Finished')
    end

    it 'should mark patient result as is_synced after integration' do
      expect(xpert_result.reload.is_sync).to eq(true)
    end
  end

  context "in case this order test synced before" do
    let(:patient)             { Patient.make institution: institution, gender: 'male', etb_patient_id: "3456" }
    let(:xpert_result)        { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago, is_sync: true }
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

    it 'should not update etb patient id' do
      expect(patient.reload.etb_patient_id).to eq('3456')
    end

    it 'should not create integration log' do
      expect(IntegrationLog.all.size).to eq(0)
    end
  end

end
