class AddFtpCredentialsToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :ftp_hostname,  :string
    add_column :institutions, :ftp_username,  :string
    add_column :institutions, :ftp_password,  :string
    add_column :institutions, :ftp_directory, :string
    add_column :institutions, :ftp_port,      :integer
    add_column :institutions, :ftp_passive,   :boolean

    remove_column :devices, :ftp_hostname,  :string
    remove_column :devices, :ftp_username,  :string
    remove_column :devices, :ftp_password,  :string
    remove_column :devices, :ftp_directory, :string
    remove_column :devices, :ftp_port,      :integer
    remove_column :devices, :ftp_passive,   :boolean
  end
end
