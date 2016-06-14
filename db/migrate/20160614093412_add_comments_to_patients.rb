class AddCommentsToPatients < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.datetime   :commented_at
      t.text       :comment
      t.string     :description
      t.string     :uuid,    index: true
      t.references :patient, index: true
      t.references :user,    index: true

      t.timestamps
    end
  end
end
