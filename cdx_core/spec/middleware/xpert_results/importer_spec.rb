require 'spec_helper'

describe XpertResults::Importer do
  let(:user)               { User.make }
  let(:encounter)          { Encounter.make }
  let(:sample)             { Sample.make encounter: encounter }
  let!(:sample_identifier) { SampleIdentifier.make lab_sample_id: '731254_99394632_D0_S2', sample: sample }
  let!(:xpert_result)      { XpertResult.make encounter: encounter }
  let(:device)             { Device.make }
  let(:parsed_message) do
    {
      "test" => {
        "core" => {
          "site_user" => "DataGen",
          "start_time" => "2016-10-13T09:00:00-05:00",
          "end_time" => "2016-10-13T10:00:00-05:00",
          "id" => "PL2M1YD4TF7F4GJCSREKU9N5XKCKEUAJ",
          "name" => "MTB-RIF Ultra RUO",
          "type" => "specimen",
          "status" => "success",
          "assays" => [
            {
              "condition"=>"mtb",
              "result"=>"positive",
              "quantitative_result"=>"MEDIUM"
            },
            {
              "condition"=>"rif",
              "result"=>"positive"
            }
          ]
        },
        "pii"=> { "custom"=> {} },
        "custom"=> {}
      },
      "sample"=>{
        "core"=>{ "id"=>"731254_99394632_D0_S2" },
        "pii"=>{ "custom"=>{} },
        "custom"=>{}
      },
      "patient"=>{
        "core"=>{},
        "pii"=>{ "custom"=>{} },
        "custom"=>{}
      },
      "encounter"=>{
        "core"=>{},
        "pii"=>{ "custom"=>{} },
        "custom"=>{}
      }
    }
  end

  before :each do
    User.current = user
  end

  describe 'link_or_create_xpert_result' do
    context 'when there is an available sample id and a test result' do
      context 'test result has been allocated' do
        before :each do
          described_class.link_or_create_xpert_result(parsed_message, device)
          xpert_result.reload
        end

        it 'should link the sample id with the test result' do
          expect(xpert_result.sample_identifier).to eq(sample_identifier)
        end

        it 'should set the test result status to pending approval' do
          expect(xpert_result.result_status).to eq('pending_approval')
        end

        it 'should link the test device to the test result' do
          expect(xpert_result.device).to eq(device)
        end
      end

      context 'test result has not allocated' do
        it 'should create an orphan test result' do

        end
      end
    end

    context 'when there is an available sample id but no test result' do
      it 'should link the sample id with the new test result' do

      end

      it 'should update the test result info' do

      end

      it 'should set the test result status to pending approval' do

      end
    end

    context 'when there is no sample id available' do
      it 'should create a new sample id' do

      end

      it 'should create an orphan test result' do

      end
    end
  end
end
