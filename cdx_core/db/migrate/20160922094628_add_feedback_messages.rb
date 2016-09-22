class AddFeedbackMessages < ActiveRecord::Migration
  def change
    create_table :feedback_messages do |t|
      t.references :institution, null: false
      t.string     :category
      t.string     :code

      t.timestamps null: false
    end

    add_index :feedback_messages, [:category, :code]
    add_index :feedback_messages, :institution_id

    create_table :custom_translations do |t|
      t.integer :localisable_id
      t.string  :localisable_type
      t.string  :lang
      t.string  :text

      t.timestamps null: false
    end

    add_index :custom_translations, [:localisable_id, :localisable_type]
    add_index :custom_translations, :lang
  end
end
