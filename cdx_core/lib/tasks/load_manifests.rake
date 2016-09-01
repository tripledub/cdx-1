require 'cdx_sync'
namespace :manifests do
  desc "Creates device models from seed manifests and creates their associated institutions with default users"
  task :load => :environment do |task, args|
    default_password = ENV['PASSWORD']
    default_email = ENV['EMAIL']
    default_institution = 'Institute One' if Settings.single_tenant
    raise 'Please specify `PASSWORD` environment variable to be used as the default password for all admins' if default_password.blank?
    raise "Please specify `EMAIL` environment variable to be used as the default email for all admins" if Settings.single_tenant && default_email.blank?

    data = {
      'genexpert' => {
        title: 'GeneXpert',
        activation: true,
        institution: default_institution || 'Cepheid',
        owner: default_email || 'cepheid_admin@instedd.org'
      },
      'epicenter_m.g.i.t._spanish' => {
        activation: true,
        institution: default_institution || 'BD',
        owner: default_email || 'bd_admin@instedd.org'
      },
      'deki_reader' => {
        activation: false,
        institution: default_institution || 'Fio Corporation',
        owner: default_email || 'fio_admin@instedd.org'
      },
      'genoscan' => {
        activation: true,
        institution: default_institution || 'Hain Lifescience',
        owner: default_email || 'hain_admin@instedd.org'
      },
      'esequant_lr3' => {
        title: 'EseQuant LR3',
        activation: false,
        institution: default_institution || 'Qiagen',
        owner: default_email || 'qiagen_admin@instedd.org'
      },
      'micro_imager' => {
        activation: false,
        institution: default_institution || 'BD',
        owner: default_email || 'bd_admin@instedd.org'
      },
      'alere_pima' => {
        activation: false,
        ftp: true,
        pattern: '^(?<sn>[A-Za-z\-0-9]+)_(?<ts>\d{1,4}-\d{1,4}-\d{1,4}_\d{1,2}-\d{1,2}-\d{1,2})_AssayID_(?<assayid>\d+|X)_\((?<assayname>[A-Za-z0-9_\-]+)\)\.csv$',
        institution: default_institution || 'Alere',
        owner: default_email || 'alere_admin@instedd.org'
      },
      'alere_q' => {
        activation: false,
        ftp: true,
        pattern: '^(?<assayid>[A-Za-z0-9\-]+)_(?<sn>[A-Za-z\-0-9]+)_(?<ts>\d{1,4}-\d{1,4}-\d{1,4}-\d{1,2}-\d{1,2}-\d{1,2})\.csv$',
        institution: default_institution || 'Alere',
        owner: default_email || 'alere_admin@instedd.org'
      }
    }

    ActiveRecord::Base.transaction do
      data.each do |name, props|
        manifest = File.read(File.join(Rails.root, 'db', 'seeds', 'manifests', "#{name}_manifest.json"))

        device_model = DeviceModel.find_or_create_by!(name: props[:title] || name.titleize) do |device_model|
          device_model.institution = Institution.find_or_create_by!(name: props[:institution]) do |institution|
            owner = User.create_with(password: default_password).find_or_create_by!(email: props[:owner]) do |u|
              u.skip_confirmation!
            end
            owner.grant_superadmin_policy if default_email && default_password
            institution.user = owner
            institution.kind = 'institution'
          end
        end

        device_model.update\
          manifest_attributes: {definition: manifest},
          supports_activation: props[:activation],
          supports_ftp: props[:ftp],
          filename_pattern: props[:pattern]

        device_model.tap(&:set_published_at).save!
      end
    end
  end
end
