# Vietnam only feature. We should allow invalid CMND codes for some patients.
class SkipSscValidation < ActiveRecord::Migration
  def change
    add_column :patients, :skip_ssc_validation, :boolean, default: false
  end
end
