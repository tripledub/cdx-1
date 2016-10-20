require 'spec_helper'

# Vietnamese customisation of the xpert results importer
describe XpertResults::VietnamImporter do
  let(:user)               { User.make }
  let(:encounter)          { Encounter.make }
  let(:sample)             { Sample.make encounter: encounter }
  let!(:sample_identifier) { SampleIdentifier.make cpd_id_sample: '99999', sample: sample }
  let(:xpert_result)       { XpertResult.make encounter: encounter }
  let(:device)             { Device.make }
  let(:parsed_message) do
    {
      "test"=>{
        "core"=>{
          "site_user"=>"Test User",
          "start_time"=>"2016-10-08T16:30:00-05:00",
          "end_time"=>"2016-10-08T17:30:00-05:00",
          "id"=>"ZUZZ6SIPXBSI2JYFBE6V8RX6C7HKIQZZ",
          "name"=>"MTB-RIF Ultra RUO",
          "type"=>"specimen",
          "status"=>"success",
          "assays"=>[
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
        "pii"=>{
          "custom"=>{}
        },
        "custom"=>{
          "xpert_patient_number"=>"11111"
        }
      },
      "sample"=>{
        "core"=>{
          "id"=>"12345"
        },
        "pii"=>{
          "custom"=>{}
        },
        "custom"=> {
          "xpert_notes"=>"CDPSAMPLE99999CDPSAMPLE"
        }
      },
      "patient"=>{
        "core"=>{},
        "pii"=>{
          "custom"=>{}
        },
        "custom"=>{}
      },
      "encounter"=>{
        "core"=>{},
        "pii"=>{
          "custom"=>{}
        },
        "custom"=>{}
      }
    }
  end

  before :each do
    User.current = user
    xpert_result.update_attribute(:result_status, 'allocated')
  end

  describe 'link_xpert_result' do
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

        it 'should update the sample identifier with vietnam information' do
          sample_identifier.reload
          expect(sample_identifier.lab_id_patient).to eq('11111')
          expect(sample_identifier.lab_id_sample).to eq('12345')
          expect(sample_identifier.cpd_id_sample).to eq('99999')
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
  end
end
