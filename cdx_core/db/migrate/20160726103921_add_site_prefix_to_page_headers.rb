class AddSitePrefixToPageHeaders < ActiveRecord::Migration
  def change
    add_column :page_headers, :site_prefix, :string
  end
end
