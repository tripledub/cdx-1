# Add comment and feedback message to encounters
class AddFeedbackToEncounters < ActiveRecord::Migration
  def change
    add_column :encounters, :comment, :string, default: ''
    add_column :encounters, :feedback_message_id, :integer

    add_index :encounters, :feedback_message_id
  end
end
