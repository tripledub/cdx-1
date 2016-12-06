# Add timezone support for sites
class AddTimeZoneToSites < ActiveRecord::Migration
  def change
    add_column :sites, :time_zone, :string, default: 'UTC'
  end
end
