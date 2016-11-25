# encoding UTF8
require 'spec_helper'
require 'fileutils'

describe DeviceMessageImporter do
  let(:user)         { User.make }
  let(:institution)  { Institution.make user_id: user.id }
  let(:device_model) { DeviceModel.make name: 'test_model' }
  let(:device)       { Device.make institution_id: institution.id, device_model: device_model }
  let(:sync_dir)     { CDXSync::SyncDirectory.new(Dir.mktmpdir('sync')) }
  let(:inbox)        { sync_dir.inbox_path(device.uuid) }

  before do
    sync_dir.ensure_sync_path!
    sync_dir.ensure_client_sync_paths! device.uuid
  end

  def write_file(content, extension, name = nil, encoding = 'UTF-8')
    file = File.join(sync_dir.inbox_path(device.uuid), "#{name || DateTime.now.strftime('%Y%m%d%H%M%S')}.#{extension}")
    File.open(file, "w", encoding: encoding) { |io| io << content }
  end

  let(:manifest) do
    Manifest.create! device_model: device.device_model, definition: %(
      {
        "metadata": {
          "version": "1",
          "api_version": "#{Manifest::CURRENT_VERSION}",
          "conditions": ["mtb"],
          "source" : { "type" : "#{source}"}
        },
        "field_mapping" : {
          "test.error_code" : {"lookup": "error_code"},
          "test.assays.result" : {
            "case": [
            {"lookup": "result"},
            [
              {"when": "positivo", "then" : "positive"},
              {"when": "positive", "then" : "positive"},
              {"when": "negative", "then" : "negative"},
              {"when": "negativo", "then" : "negative"},
              {"when": "inválido", "then" : "n/a"}
            ]
          ]},
          "test.status" : {
            "case": [
            {"lookup": "result"},
            [
              {"when": "inválido", "then" : "invalid"},
              {"when": "invalid", "then" : "invalid"},
              {"when": "*", "then" : "success"}
            ]
          ]}
        }
      }
    )
  end

  context "csv" do
    let(:source) { "csv" }

    it 'parses a csv from sync dir' do
      manifest
      write_file(%(error_code;result\n0;positive\n1;negative), 'csv')
      DeviceMessageImporter.new.import_from sync_dir

      expect(DeviceMessage.first.index_failure_reason).to be_nil
    end

    it 'parses a csv in utf 16' do
      manifest

      write_file(%(error_code;result\r\n0;positivo\r\n1;inválido\r\n), 'csv', nil, 'UTF-16LE')
      allow(CharDet).to receive(:detect).and_return('encoding' => 'UTF-16LE', 'confidence' => 1.0)
      DeviceMessageImporter.new.import_from sync_dir

      expect(DeviceMessage.first.index_failure_reason).to be_nil
    end
  end

  context "json" do
    let(:source) { "json" }

    it 'parses a json from sync dir' do
      manifest
      write_file('[{"error_code": "0", "result": "positive"}, {"error_code": "1", "result": "negative"}]', 'json')
      DeviceMessageImporter.new("*.json").import_from sync_dir

      expect(DeviceMessage.first.index_failure_reason).to be_nil
    end

    it 'parses a json from sync dir registering multiple extensions' do
      manifest
      write_file('[{"error_code": "0", "result": "positive"}, {"error_code": "1", "result": "negative"}]', 'json')
      DeviceMessageImporter.new("*.{csv,json}").import_from sync_dir

      expect(DeviceMessage.first.index_failure_reason).to be_nil
    end

    it 'parses a json from sync dir registering multiple extensions using import single' do
      manifest
      write_file(
        '[{"error_code": "0", "result": "positive"}, {"error_code": "1", "result": "negative"}]',
        'json',
        'mytestfile'
      )
      DeviceMessageImporter.new("*.{csv,json}")
        .import_single(sync_dir, File.join(sync_dir.inbox_path(device.uuid), "mytestfile.json"))

      expect(DeviceMessage.first.index_failure_reason).to be_nil
    end
  end

  context "real scenarios" do
    context 'epicenter headless_es' do
      let!(:device_model) { DeviceModel.make name: 'epicenter_headless_es' }
      let!(:manifest)     { load_manifest 'epicenter_m.g.i.t._spanish_manifest.json', device_model }

      it "parses csv in utf-16le" do
        copy_sample_csv 'epicenter_headless_sample_utf16.csv', inbox
        DeviceMessageImporter.new("*.csv").import_from sync_dir

        expect(DeviceMessage.first.index_failure_reason).to be_nil
      end
    end

    context 'cepheid' do
      let!(:device_model) { DeviceModel.make name: "GX Model I" }
      let!(:manifest)     { load_manifest 'genexpert_manifest.json', device_model }

      context 'sample' do
        before do
          copy_sample_json('genexpert_sample.json', inbox)
          DeviceMessageImporter.new("*.json").import_from sync_dir
        end

        it "should parse cepheid's document" do
          expect(DeviceMessage.first.index_failure_reason).to be_nil
        end
      end
    end

    context 'genoscan' do
      let(:device_model) { DeviceModel.make name: 'genoscan' }
      let!(:manifest) { load_manifest 'genoscan_manifest.json', device_model }

      it 'parses csv' do
        copy_sample_csv 'genoscan_sample.csv', inbox
        DeviceMessageImporter.new("*.csv").import_from sync_dir

        expect(DeviceMessage.first.index_failure_reason).to be_nil

        dbtests = TestResult.all
        expect(dbtests.size).to eq(13)
      end
    end

    context 'alere q' do
      let(:device_model) { DeviceModel.make name: 'alere q' }
      let!(:manifest) { load_manifest 'alere_q_manifest.json', device_model }

      it 'parses csv' do
        copy_sample_csv 'alere_q.csv', inbox
        DeviceMessageImporter.new("*.csv").import_from sync_dir

        expect(DeviceMessage.first.index_failure_reason).to be_nil

        dbtests = TestResult.all
        expect(dbtests.size).to eq(77)
      end
    end

    context 'alere pima' do
      let(:device_model) { DeviceModel.make name: 'alere pima' }
      let!(:manifest) { load_manifest 'alere_pima_manifest.json', device_model }

      it 'parses csv' do
        copy_sample_csv 'alere_pima.csv', inbox
        DeviceMessageImporter.new("*.csv").import_from sync_dir

        expect(DeviceMessage.first.index_failure_reason).to be_nil

        dbtests = TestResult.all
        expect(dbtests.size).to eq(38)
      end
    end

    context 'fio' do
      let(:device_model) { DeviceModel.make name: 'FIO' }
      let!(:manifest) { load_manifest 'deki_reader_manifest.json', device_model }

      it 'parses xml' do
        copy_sample_xml 'deki_reader_sample.xml', inbox
        DeviceMessageImporter.new("*.xml").import_from sync_dir

        expect(DeviceMessage.first.index_failure_reason).to be_nil

        expect(TestResult.count).to eq(1)
        db_test = TestResult.first
        expect(db_test.test_id).to eq('12345678901234567890')
      end
    end

    context 'BDMicroImager' do
      let!(:device_model) { DeviceModel.make name: "BD MicroImager" }
      let!(:manifest) { load_manifest 'micro_imager_manifest.json', device_model }

      it "should parse bd micro's document" do
        copy_sample_json('micro_imager_sample.json', inbox)
        DeviceMessageImporter.new("*.json").import_from sync_dir
        expect(DeviceMessage.first.index_failure_reason).to be_nil
      end
    end
  end
end
