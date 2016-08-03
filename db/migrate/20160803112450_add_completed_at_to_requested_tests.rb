class AddCompletedAtToRequestedTests < ActiveRecord::Migration
  def change
    add_column :requested_tests, :completed_at, :datetime
    add_index :requested_tests, :completed_at
  end
end
