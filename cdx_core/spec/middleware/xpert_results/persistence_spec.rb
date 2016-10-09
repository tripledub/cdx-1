require 'spec_helper'

describe XpertResults::Persistence do
  let(:device)        { Device.make }
  let(:encounter)     { Encounter.make }
  let!(:xpert_result) { XpertResult.make encounter: encounter }
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

  describe 'update_from_device_message' do
    before :each do
      described_class.update_from_device_message(encounter, parsed_message)
      xpert_result.reload
    end

    it 'should update the tuberculosis result info' do
      expect(xpert_result.tuberculosis).to eq('detected')
    end

    it 'should update the rifampicin result info' do
      expect(xpert_result.rifampicin).to eq('detected')
    end

    it 'should set the test_id' do
      expect(xpert_result.test_id).to eq('PL2M1YD4TF7F4GJCSREKU9N5XKCKEUAJ')
    end
  end

  describe 'create_orphan_result' do
    xit 'should create a new orphan xpert result' do
      expect { described_class.create_orphan_result(encounter, parsed_message) }.to change { Counter.count }.from(1).to(2)
    end
  end
end

# DeviceMessage.parsed_message
#   {
#     "test" => {
#       "core" => {
#         "site_user" => "DataGen",
#         "start_time" => "2016-10-13T09:00:00-05:00",
#         "end_time" => "2016-10-13T10:00:00-05:00",
#         "id" => "PL2M1YD4TF7F4GJCSREKU9N5XKCKEUAJ",
#         "name" => "MTB-RIF Ultra RUO",
#         "type" => "specimen",
#         "status" => "success",
#         "assays" => [
#           {
#             "condition"=>"mtb",
#             "result"=>"positive",
#             "quantitative_result"=>"MEDIUM"
#           },
#           {
#             "condition"=>"rif",
#             "result"=>"positive"
#           }
#         ]
#       },
#       "pii"=> { "custom"=> {} },
#       "custom"=> {}
#     },
#     "sample"=>{
#       "core"=>{ "id"=>"731254_99394632_D0_S2" },
#       "pii"=>{ "custom"=>{} },
#       "custom"=>{}
#     },
#     "patient"=>{
#       "core"=>{},
#       "pii"=>{ "custom"=>{} },
#       "custom"=>{}
#     },
#     "encounter"=>{
#       "core"=>{},
#       "pii"=>{ "custom"=>{} },
#       "custom"=>{}
#     }
#   }
