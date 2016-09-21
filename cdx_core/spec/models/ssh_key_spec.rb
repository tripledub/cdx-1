require 'spec_helper'

require 'tempfile'

describe SshKey do
  let!(:device) { Device.make }
  let!(:ssh_key) { SshKey.create!(
      public_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4'+
          'hzyCbJQ5RgrZPFz+rTscTuJ5NPuBIKiinXwkA38CE9+N37L8q9kMqxsbDumVFbamYVlS9fsmF1TqRRhobfJfZGpt'+
          'kcthQde83FWHQGaEQn8T4SG055N5SWNRjQTfMaK0uTTQ28BN44dhLluF/zp4UDHOKRVBrJY4SZq1M5ytkMc6mlZW'+
          'bCAzqtIUUJOMKz4lHn5Os/d8temlYskaKQ1n+FuX5qJXNr1SW8euH72fjQndu78DCwVNwnnrG+nEe3a9m2QwL5xn'+
          'X8f1ohAZ9IG41hwIOvB5UcrFenqYIpMPBCCOnizUcyIFJhegJDWh2oWlBo041emGOX3VCRjtGug3 ' +
          'fbulgarelli@Manass-MacBook-2.local',
      device: device) }

  before { device.ssh_key = ssh_key }

  describe '::clients' do
    let(:clients) { SshKey.clients }

    it { expect(clients.size).to eq 1 }

    it { expect(clients.first.public_key).to include 'ssh-rsa AAAAB3' }
    it { expect(clients.first.id).to eq device.uuid }

  end

  describe '::regenerate_authorized_keys!' do
    let!(:authorized_keys_path) { Tempfile.new('authorized_keys').tap(&:close) }
    let!(:sync_dir_path) { Dir.mktmpdir('sync') }

    before do
      a = authorized_keys_path
      s = sync_dir_path
      CDXSync.define_singleton_method(:default_authorized_keys_path) { a }
      CDXSync.define_singleton_method(:default_sync_dir_path) { s }
    end

    before { SshKey.regenerate_authorized_keys! }

    it { expect(File.readlines(CDXSync.default_authorized_keys_path).size).to eq 1 }
  end

  it "deletes other ssh keys with same public key" do
    other_ssh_key = SshKey.create! public_key: ssh_key.public_key, device: Device.make
    expect(SshKey.all.to_a).to eq([other_ssh_key])
  end
end
