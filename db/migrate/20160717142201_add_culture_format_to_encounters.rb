class AddCultureFormatToEncounters < ActiveRecord::Migration
  def change
    add_column :encounters, :culture_format, :string
  end
end
