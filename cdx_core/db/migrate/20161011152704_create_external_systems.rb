class CreateExternalSystems < ActiveRecord::Migration
  def change
    create_table :external_systems do |t|
      t.string :prefix
      t.string :name
      t.timestamps
    end
  end
end
