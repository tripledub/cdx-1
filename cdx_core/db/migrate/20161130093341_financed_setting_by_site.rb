# Allow sites to mark test orders as financed automatically
class FinancedSettingBySite < ActiveRecord::Migration
  def change
    add_column :sites, :finance_approved, :boolean, default: false
  end
end
