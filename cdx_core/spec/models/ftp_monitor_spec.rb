require 'spec_helper'

describe FtpMonitor, elasticsearch: true do
  context 'orchestration' do
    it 'should group devices by ftp info' do
      dm = DeviceModel.make(supports_ftp: true, filename_pattern: '(?<sn>.+)')
      i1 = Institution.make(ftp_hostname: 'example.com')
      i2 = Institution.make(ftp_hostname: 'example.com')
      i3 = Institution.make(ftp_hostname: 'example.com', ftp_port: 1000)
      i4 = Institution.make(ftp_hostname: 'example.com', ftp_port: 1000)
      i5 = Institution.make(ftp_hostname: 'example.com', ftp_port: 2000)

      groups = FtpMonitor.new.device_groups
      expect(groups).to have(3).items
      expect(groups.to_a).to contain_exactly\
        [FtpInfo.new(hostname: 'example.com'), [i1, i2]],
        [FtpInfo.new(hostname: 'example.com', port: 1000), [i3, i4]],
        [FtpInfo.new(hostname: 'example.com', port: 2000), [i5]]
    end
  end

  context FtpMonitor::FtpProcessor do
    let(:ftp) do
      instance_double('Net::FTP').tap do |ftp|
        %i(connect login chdir quit passive=).each do |msg|
          allow(ftp).to receive(msg)
        end
        allow(ftp).to receive(:nlst).and_return(files)
      end
    end

    before(:each) { expect(Net::FTP).to receive(:new).and_return(ftp) }

    let(:ftp_info) { FtpInfo.new(hostname: 'example.com') }
    let(:files)    { [] }

    let(:model1)  { DeviceModel.make(supports_ftp: true, filename_pattern: 'M1_(?<sn>[A-Z0-9]+)_(?<ts>\d{8})') }
    let(:model2)  { DeviceModel.make(supports_ftp: true, filename_pattern: 'M2_(?<sn>[A-Z0-9]+)') }
    let(:device1) { Device.make(device_model: model1, serial_number: 'A1000') }
    let(:device2) { Device.make(device_model: model2, serial_number: 'A2000') }
    let(:device3) { Device.make(device_model: model2, serial_number: 'A3000') }

    let(:subject) { FtpMonitor::FtpProcessor.new(ftp_info, [device1, device2, device3]) }

    context 'when listing' do
      let(:files) { %w(/foo/f1.csv /foo/f2.csv /bar/f1.csv /bar/f2.csv) }

      it 'should request to download all files' do
        expect(subject).to receive(:download_files).with(files).and_return([])
        expect(subject.process!).to be_nil
      end

      it 'should request to download unseen files' do
        FileMessage.create!(ftp_info: ftp_info, filename: files[0], status: 'success')
        FileMessage.create!(ftp_info: ftp_info, filename: files[1], status: 'failed')
        FileMessage.create!(ftp_info: ftp_info, filename: files[2], status: 'error')

        expect(subject).to receive(:download_files).with(files[2..3]).and_return([])
        expect(subject.process!).to be_nil
      end
    end

    context 'when connecting' do
      let(:ftp_info) { FtpInfo.new('example.com', 2000, '/foo/bar', 'jdoe', 'pass') }

      it 'should use provided ftp info' do
        expect(ftp).to receive(:connect).with('example.com', 2000)
        expect(ftp).to receive(:login).with('jdoe', 'pass')
        expect(ftp).to receive(:chdir).with('/foo/bar')
        subject.open_ftp!
      end
    end

    context 'when downloading' do
      let(:files) { %w(/foo/f1.csv /bar/f1.csv) }

      it 'should download all files from ftp' do
        files.each do |f|
          expect(ftp).to receive(:getbinaryfile).with(f, kind_of(String)) do |remote, local|
            File.open(local, 'w') { |f| f.write("CONTENTS OF #{remote}") }
          end
        end

        subject.open_ftp!
        downloaded = subject.download_files(files)

        expect(downloaded.map(&:first)).to eq(files)
        expect(downloaded.map(&:last)).to_not be_nil

        downloaded.each do |remote, file|
          file.rewind
          expect(file.read).to eq("CONTENTS OF #{remote}")
        end
      end
    end

    context 'when processing' do
      let(:file_messages) { FileMessage.all }

      # Expect ftp client to receive a request to download a remote file,
      # and write the mock contents to the requested temp file location
      before(:each) do
        files.each do |f|
          expect(ftp).to(receive(:getbinaryfile).with(f, kind_of(String))) do |remote, local|
            File.open(local, 'w') { |f| f.write("CONTENTS OF #{remote}") }
          end
        end
      end

      def receive_new_for(device, remote, &block)
        receive(:new)
          .with(device: device, plain_text_data: "CONTENTS OF #{remote}")
          .and_wrap_original do |m, *args|
          dm = m.call(*args)
          allow(dm).to receive(:parsed_messages).and_return([])
          allow(dm).to receive(:process).and_return([])
          block.call(dm) if block
          dm
        end
      end

      context 'for a single device' do
        let(:files) do
          %w(
            /foo/M1_A1000_20160101.csv
            /foo/M1_A1000_20160102.csv
          )
        end

        it 'should process all files' do
          expect(DeviceMessage).to receive_new_for(device1, files[0])
          expect(DeviceMessage).to receive_new_for(device1, files[1])

          expect(subject.process!).to be_nil

          expect(file_messages).to have(2).items
          file_messages.zip(files).each do |file_message, file_name|
            expect(file_message.ftp_info).to eq(ftp_info)
            expect(file_message.status).to eq('success')
            expect(file_message.filename).to eq(file_name)
            expect(file_message.device).to eq(device1)
            expect(file_message.device_message).to be_not_nil
            expect(file_message.device_message.plain_text_data).to eq("CONTENTS OF #{file_name}")
          end
        end
      end

      context 'for multiple devices' do
        let(:files) do
          %w(
            /foo/M1_A1000_20160101.csv
            /foo/M1_A1000_20160102.csv
            /foo/M2_A2000_A.csv
            /foo/M2_A2000_B.csv
            /foo/M2_A3000_A.csv
          )
        end

        it 'should match each file to the corresponding device' do
          expected_devices = [device1, device1, device2, device2, device3]
          files.zip(expected_devices).each do |file, device|
            expect(DeviceMessage).to receive_new_for(device, file)
          end

          expect(subject.process!).to be_nil
          expect(file_messages).to have(files.length).items
          file_messages.zip(files, expected_devices).each do |file_message, file_name, device|
            expect(file_message.ftp_info).to eq(ftp_info)
            expect(file_message.status).to eq('success')
            expect(file_message.filename).to eq(file_name)
            expect(file_message.device).to eq(device)
            expect(file_message.device_message).to be_not_nil
            expect(file_message.device_message.plain_text_data).to eq("CONTENTS OF #{file_name}")
          end
        end

        it 'should mark failed files' do
          expected_devices = [device1, device1, device2, device2, device3]
          files.zip(expected_devices).each do |file, device|
            expect(DeviceMessage).to(receive_new_for(device, file) do |dm|
              allow(dm).to receive(:process).and_raise('Custom error') if device == device1
              allow(dm).to receive(:save).and_return(false) if device == device2
            end)
          end

          expect(subject.process!).to be_nil
          expect(file_messages).to have(files.length).items

          file_messages.zip(files, expected_devices).each do |file_message, file_name, device|
            expect(file_message.ftp_info).to eq(ftp_info)
            expect(file_message.status).to eq(device == device3 ? 'success' : 'failed')
            expect(file_message.filename).to eq(file_name)
            expect(file_message.device).to eq(device)
            expect(file_message.device_message).to(device == device2 ? be_nil : be_not_nil)
          end
        end
      end

      context 'with non matching files' do
        let(:files) do
          %w(
            /foo/M1_A1000_20160101.csv
            /foo/M1_A1000.csv
            /foo/M2_A1000.csv
          )
        end

        it 'should skip non matching files' do
          expect(DeviceMessage).to receive_new_for(device1, files[0])

          expect(subject.process!).to be_nil
          expect(file_messages).to have(1).item
          expect(file_messages[0].filename).to eq(files[0])
        end
      end
    end

    context 'a zip file' do
      let(:file_messages) { FileMessage.all }
      let(:files) { %w(alere_q.csv.zip) }
      let(:temp_dir) { Dir.mktmpdir('ftp') }
      let(:device_model) do
        # if this pattern change, also update it in load_manifests.rake
        DeviceModel.make(
          name: 'alere_q',
          supports_ftp: true,
          filename_pattern:
            '^(?<assayid>[A-Za-z0-9\-]+)_(?<sn>[A-Za-z\-0-9]+)_(?<ts>\d{1,4}-\d{1,4}-\d{1,4}-\d{1,2}-\d{1,2}-\d{1,2})\.csv$'
        )
      end
      let!(:manifest) { load_manifest 'alere_q_manifest.json', device_model }
      let!(:device) do
        Device.make(
          device_model: device_model,
          serial_number: 'NAT-04000443'
        )
      end
      let(:tempfile) { Tempfile.new('alere_q.csv.zip', temp_dir) }
      let(:tempfiles) { [['alere_q.csv.zip', tempfile]] }

      before(:each) { copy_sample_csv('alere_q.csv.zip', tempfile.path) }

      let(:subject) { FtpMonitor::FtpProcessor.new(ftp_info, [device]) }

      it 'should unzip and process the contents' do
        expect(subject).to receive(:download_files).with(files).and_return(tempfiles)

        expect(subject.process!).to be_nil

        expect(file_messages).to have(1).item
        expect(file_messages[0].filename).to eq('01-02_NAT-04000443_2016-03-29-13-24-39.csv')

        tests = all_elasticsearch_tests.sort_by { |test| test['_source']['test']['assays'].first['result'] }
        test = tests.first['_source']['test']
        expect(test['assays'].first['result']).to eq('negative')
        test = tests.last['_source']['test']
        expect(test['assays'].first['result']).to eq('positive')
      end
    end
  end
end
