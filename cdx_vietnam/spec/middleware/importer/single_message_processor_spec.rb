require 'spec_helper'

describe Importer::SingleMessageProcessor do
  let(:encounter)                { Encounter.make }
  let(:device_message)           { DeviceMessage.make }
  let(:device_message_processor) { Importer::DeviceMessageProcessor.new(device_message) }
  let(:sample)                   { Sample.make encounter: encounter }
  let!(:sample_identifier)       { SampleIdentifier.make cpd_id_sample: 'A99999', sample: sample }
  let(:xpert_result)             { XpertResult.make encounter: encounter }
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
          "xpert_notes"=>"CDPSAMPLEA99999CDPSAMPLE"
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
    it 'should call the vietnam importer' do
      expect(XpertResults::VietnamImporter).to receive(:valid_gene_xpert_result_and_sample?)

      described_class.new(device_message_processor, parsed_message).process
    end

    context 'when there is a valid sample id' do
      it 'should call the linker' do
        xpert_result.update_attribute(:result_status, 'allocated')
        Device.any_instance.stub(:model_is_gen_expert?).and_return(true)
        expect(XpertResults::VietnamImporter).to receive(:link_xpert_result)

        described_class.new(device_message_processor, parsed_message).process
      end
    end

    context 'it should generate an xpert result' do
      before :each do
        xpert_result.update_attribute(:result_status, 'allocated')
        Device.any_instance.stub(:model_is_gen_expert?).and_return(true)
      end

      it 'when parsed message has all required info' do
        described_class.new(device_message_processor, parsed_message).process

        expect(XpertResult.first.sample_identifier.cpd_id_sample).to eq('A99999')
      end

      it 'when test custom xpert_patient_number is not available' do
        parsed_message['test']['custom'].delete('xpert_patient_number')
        described_class.new(device_message_processor, parsed_message).process

        expect(XpertResult.first.sample_identifier.cpd_id_sample).to eq('A99999')
      end

      it 'when notes field has lower case matching characters' do
        parsed_message['sample']['custom']['xpert_notes'] = 'cdpsampleA99999CDPsample'
        described_class.new(device_message_processor, parsed_message).process

        expect(XpertResult.first.sample_identifier.cpd_id_sample).to eq('A99999')
      end

      it 'when notes field has lower case sample_id and matching characters' do
        parsed_message['sample']['custom']['xpert_notes'] = 'cdpsamplea99999CDPsample'
        described_class.new(device_message_processor, parsed_message).process

        expect(XpertResult.first.sample_identifier.cpd_id_sample).to eq('A99999')
      end

      it 'when sample core id is not available' do
        parsed_message['sample'].delete('core')
        described_class.new(device_message_processor, parsed_message).process

        expect(XpertResult.first.sample_identifier.cpd_id_sample).to eq('A99999')
      end
    end

    context 'it should generate an orphan result ' do
      before :each do
        xpert_result.update_attribute(:result_status, 'allocated')
        Device.any_instance.stub(:model_is_gen_expert?).and_return(true)
      end

      it 'when notes field is empty' do
        parsed_message['sample']['custom']['xpert_notes'] = ''
        described_class.new(device_message_processor, parsed_message).process

        expect(TestResult.first.sample_identifier.entity_id).to eq('12345')
      end

      it 'when notes field is not present' do
        parsed_message['sample']['custom'].delete('xpert_notes')
        described_class.new(device_message_processor, parsed_message).process

        expect(TestResult.first.sample_identifier.entity_id).to eq('12345')
      end

      it 'when notes field does not have a valid sample id mask' do
        parsed_message['sample']['custom']['xpert_notes'] = 'Some other content not related to sample Id'
        described_class.new(device_message_processor, parsed_message).process

        expect(TestResult.first.sample_identifier.entity_id).to eq('12345')
      end

      it 'when notes field does not have a valid sample id inside mask' do
        parsed_message['sample']['custom']['xpert_notes'] = 'Some other content not CDPSAMPLE CDPSAMPLE related to sample Id'
        described_class.new(device_message_processor, parsed_message).process

        expect(TestResult.first.sample_identifier.entity_id).to eq('12345')
      end

      it 'when sample custom entry is not available' do
        parsed_message['sample'].delete('custom')
        described_class.new(device_message_processor, parsed_message).process

        expect(TestResult.first.sample_identifier.entity_id).to eq('12345')
      end
    end
  end
end
