# Add timezone support for sites
class AddTimeZoneToSites < ActiveRecord::Migration
  def change
    add_column :sites, :time_zone, :string, default: 'UTC'
    rename_column :users, :timestamps_in_device_time_zone, :timestamps_in_site_time_zone
  end
end
