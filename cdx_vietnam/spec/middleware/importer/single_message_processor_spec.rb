require 'spec_helper'

describe Importer::SingleMessageProcessor do
  let(:device_message) { DeviceMessage.make }
  let(:device_message_processor) { Importer::DeviceMessageProcessor.new(device_message) }
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
          "xpert_notes"=>"CPDSAMPLE99999CPDSAMPLE"
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

  describe 'process' do
    subject { described_class.new(device_message_processor, parsed_message) }

    it 'should call the vietnam importer' do
      expect(XpertResults::VietnamImporter).to receive(:valid_gene_xpert_result_and_sample?)

      subject.process
    end
  end
end
