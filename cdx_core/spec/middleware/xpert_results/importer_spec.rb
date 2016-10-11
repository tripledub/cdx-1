require 'spec_helper'

describe XpertResults::Importer do
  let(:user)               { User.make }
  let(:encounter)          { Encounter.make }
  let(:sample)             { Sample.make encounter: encounter }
  let!(:sample_identifier) { SampleIdentifier.make lab_sample_id: '731254_99394632_D0_S2', sample: sample }
  let(:xpert_result)       { XpertResult.make encounter: encounter }
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
    xpert_result.update_attribute(:result_status, 'allocated')
  end

  describe 'link_or_create_xpert_result' do
    context 'when there is an available sample id and a test result' do
      context 'test result has been allocated' do
        before :each do
          described_class.link_xpert_result(parsed_message, device)
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
    end
  end

  describe 'valid_gene_xpert_result_and_sample?' do
    context 'valid device, sample and xpert result' do
      it 'should return true' do
        device.stub(:model_is_gen_expert?).and_return(true)
        expect(described_class.valid_gene_xpert_result_and_sample?(device, parsed_message)).to be true
      end
    end

    context 'valid device and xpert result' do
      it 'should return false' do
        sample_identifier.update_attribute(:lab_sample_id, 'not_valid')
        expect(described_class.valid_gene_xpert_result_and_sample?(device, parsed_message)).to be false
      end
    end

    context 'valid device and sample' do
      it 'should return false' do
        xpert_result.update_attribute(:result_status, 'rejected')
        expect(described_class.valid_gene_xpert_result_and_sample?(device, parsed_message)).to be false
      end
    end

    context 'valid sample and xpert result' do
      it 'should return false' do
        device.stub(:model_is_gen_expert?).and_return(false)
        expect(described_class.valid_gene_xpert_result_and_sample?(device, parsed_message)).to be false
      end
    end
  end
end
