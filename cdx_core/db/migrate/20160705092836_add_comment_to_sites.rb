class AddCommentToSites < ActiveRecord::Migration
  def change
    add_column :sites, :comment, :text
  end
end
