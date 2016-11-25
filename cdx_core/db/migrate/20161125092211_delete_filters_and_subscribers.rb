# Remove unused filters and subsribers
class DeleteFiltersAndSubscribers < ActiveRecord::Migration
  def change
    drop_table :filters
    drop_table :subscribers
  end
end
